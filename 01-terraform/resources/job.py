
import sys
import argparse
import logging

from pyspark.sql import SparkSession, SQLContext
from pyspark.sql.functions import udf, col, sum, count, min
from pyspark.sql.types import IntegerType, StringType, FloatType
from textblob import TextBlob


def sentiment_analysis(comment):
    blob = TextBlob(comment)
    return 1 if blob.sentiment.polarity >= 0 else 0


# Parsing arguments (database conection data)

parser = argparse.ArgumentParser()
parser.add_argument("--host")
parser.add_argument("--port")
parser.add_argument("--user")
parser.add_argument("--pw")
parser.add_argument("--db")
parser.add_argument("--schema")
parser.add_argument("--table")
parser.add_argument("--raw-bucket-uri")
parser.add_argument("--staging-bucket-uri")
args = parser.parse_args(sys.argv)

# SQL variables
HOST = args.host
PORT = args.port
USER = args.user
PW = args.pw
DATABASE = args.db
SCHEMA = args.schema
TABLE = args.table

# CLoud storage variables
RAW_BUCKET_URI = args.raw_bucket_uri
STAGING_BUCKET_URI = args.staging_bucket_uri

# Init spark session
spark = (SparkSession
         .builder
         .config("spark.jars", "https://jdbc.postgresql.org/download/postgresql-42.3.1.jar")
         .getOrCreate())

# Read data from SQL
user_purchase_df = (spark.read
                    .format("jdbc")
                    .option("url", f"jdbc:postgresql://{HOST}:{PORT}/{DATABASE}")
                    .option("dbtable", f"{SCHEMA}.{TABLE}")
                    .option("user", USER)
                    .option("password", PW)
                    .option("driver", "org.postgresql.Driver")
                    .load())

# Read data from Cloud Storage
movie_review_df = spark.read.option("header", True).csv(
    f"{RAW_BUCKET_URI}/movie_review.csv")

# Sentiment analysis user defined function
udf_sentiment_analysis = udf(sentiment_analysis, IntegerType())

# Reviews DF has columns: cid, positive_review
reviews_df = movie_review_df.withColumn(
    "positive_review",
    udf_sentiment_analysis(col("review_str"))
).select("cid", "positive_review")

# Reduce size of dataframes by grouping information by customer id

user_purchase_gb_df = user_purchase_df.groupBy("customer_id").agg(
    sum(col("quantity") * col("unit_price")).alias("amount_spent"),
    min(col("country")).alias("country")
)

reviews_gb_df = reviews_df.groupBy("cid").agg(
    sum(col("positive_review")).alias("review_score"),
    count("cid").alias("review_count")
)

user_purchase_gb_df.createOrReplaceTempView("user_purchase")
reviews_gb_df.createOrReplaceTempView("reviews")

behavior_metrics_df = spark.sql("""
    SELECT 
        user_purchase.customer_id as customer_id,
        user_purchase.amount_spent as amount_spent,
        reviews.review_score as review_score, 
        reviews.review_count as review_count,
        user_purchase.country as country
    FROM
        user_purchase INNER JOIN reviews
        ON user_purchase.customer_id == reviews.cid
""")

# Store data to parquet files in staging bucket

user_purchase_df.repartition(1).write.parquet(
    f"{STAGING_BUCKET_URI}/user_purchase")
reviews_df.repartition(1).write.parquet(
    f"{STAGING_BUCKET_URI}/reviews")
behavior_metrics_df.repartition(1).write.parquet(
    f"{STAGING_BUCKET_URI}/behavior_metrics")
