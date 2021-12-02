import sys
import argparse
import logging

# import findspark
from pyspark.sql import SparkSession
from pyspark.ml.feature import Tokenizer
from pyspark.ml.feature import StopWordsRemover
import pyspark.sql.functions as f

# Parsing arguments (database conection data)

parser = argparse.ArgumentParser()
parser.add_argument("--host")
parser.add_argument("--port")
parser.add_argument("--user")
parser.add_argument("--pw")
parser.add_argument("--db")
parser.add_argument("--schema")
parser.add_argument("--table")
parser.add_argument("--raw-bucket")
parser.add_argument("--staging-bucket")
args = parser.parse_args(arr)

# SQL variables
HOST = args.host
PORT = args.port
USER = args.user
PW = args.pw
DATABASE = args.db
SCHEMA = args.schema
TABLE = args.table

# CLoud storage variables
RAW_BUCKET = args.raw_bucket
STAGING_BUCKET = args.staging_bucket
MOVIE_REVIEW_OBJECT = "movie_review.csv"

# Init spark session
# findspark.init()
spark = SparkSession.builder.getOrCreate()

# Read data from SQL
user_purchase_data = (spark.read
                      .format("jdbc")
                      .option("url", f"jdbc:postgresql://{HOST}:{PORT}/{DATABASE}")
                      .option("dbtable", f"{SCHEMA}.{TABLE}")
                      .option("user", USER)
                      .option("password", PW)
                      .option("driver", "org.postgresql.Driver")
                      .load())

# Read data from Cloud Storage
movie_review_data = spark.read.csv(f"{RAW_BUCKET}/{MOVIE_REVIEW_OBJECT}")


# Tokenization
# tokenizer = Tokenizer(inputCol="review_str", outputCol="review_token")
# tokenized = tokenizer.transform(
#     movie_review_data).select('cid', 'review_token')

# # Stopwords deletion
# remover = StopWordsRemover(inputCol='review_token', outputCol='token_clean')
# tokenized_without_stopwords = remover.transform(
#     tokenized).select('cid', 'token_clean')


# classified = tokenized_without_stopwords.withColumn(
#     "positive_review",
#     f
#     .array_contains(f.col("token_clean"), "good")
#     .cast('integer')
# )


# output_classified = classified.select("cid", "positive_review")
# output_classified.write.csv(f"{STAGING_BUCKET}/review.csv")

movie_review_data.write.csv(f"{STAGING_BUCKET}/purchase.csv")
