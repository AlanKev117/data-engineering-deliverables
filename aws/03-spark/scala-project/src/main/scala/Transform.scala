import com.amazonaws.services.glue.{GlueContext, DynamicRecord, DynamicFrame}
import com.amazonaws.services.glue.util.{Job, GlueArgParser, JsonOptions}
import com.amazonaws.services.glue.types._
import org.apache.spark.SparkContext
import org.apache.spark.sql.{DataFrame, Row, SparkSession}
import org.apache.spark.sql.functions._
import java.util.Properties
import scala.collection.convert.wrapAll._
import scala.collection.JavaConverters._

object Logics {

  def movieReviewLogicHasGood(
      movieReview: DataFrame,
      spark: SparkSession
  ): DataFrame = {

    // Syntax sugar and data type conversions.
    import spark.implicits._

    // Transformation using word matching.
    val hasGoodUdf = udf { (rev: String) => if (rev.contains("good")) 1 else 0 }
    movieReview
      .toDF("customer_id", "review_str", "review_id")
      .na
      .drop()
      .select(
        'customer_id.cast("int").as('customer_id),
        hasGoodUdf('review_str).as('positive_review),
        'review_id.cast("int").as('review_id)
      )
  }

  def logReviewsLogic(
      logReviews: DataFrame,
      spark: SparkSession
  ): DataFrame = {

    val osToBrowser = Map(
      "apple ios" -> "safari",
      "apple macos" -> "safari",
      "google android" -> "chrome",
      "linux" -> "firefox",
      "microsoft windows" -> "edge"
    )

    // Create UDF to map OS property to browser.
    val osToBrowserUdf = udf { (os: String) =>
      osToBrowser.getOrElse(os.toLowerCase, "chrome")
    }

    // Enable DF to be used in Spark SQL sentences.
    logReviews.na.drop().createOrReplaceTempView("log_reviews")

    // Apply transformation to DF using Spark SQL string.
    spark
      .sql("""
        SELECT
          id_review AS log_id,
          xpath_string(log, '//logDate') AS log_date,
          xpath_string(log, '//device') AS device,
          xpath_string(log, '//location') AS location,
          xpath_string(log, '//os') AS os,
          xpath_string(log, '//ipAddress') AS ip,
          xpath_string(log, '//phoneNumber') AS phone_number
        FROM
          log_reviews
      """)
      .withColumn("browser", osToBrowserUdf(col("os")))
      .select(
        col("log_id").cast("int").as('log_id),
        to_date(col("log_date"), "MM-dd-yyyy").as("log_date"),
        col("device"),
        col("os"),
        col("location"),
        col("browser"),
        col("ip"),
        col("phone_number")
      )
  }
}

object ETL {

  def main(sysArgs: Array[String]) = {
    // Instanciate Glue's Spark Session
    val sc: SparkContext = SparkContext.getOrCreate()
    val glueContext: GlueContext = new GlueContext(sc)
    val spark: SparkSession = glueContext.getSparkSession

    // Parse script args.
    val params = Seq(
      "JOB_NAME",
      "db_endpoint",
      "db_name",
      "db_table",
      "db_user",
      "db_password",
      "movie_rev_path",
      "log_rev_path",
      "staging_path"
    )

    val args =
      GlueArgParser.getResolvedOptions(sysArgs, params.toArray)
    Job.init(args("JOB_NAME"), glueContext, args.asJava)

    val Endpoint = args("db_endpoint")
    val Database = args("db_name")
    val Table = args("db_table")
    val User = args("db_user")
    val Password = args("db_password")
    val MovieRevPath = args("movie_rev_path")
    val LogRevPath = args("log_rev_path")
    val StagingPath = args("staging_path")

    // Extract

    val userPurchase = (spark.read
      .format("jdbc")
      .option("url", s"jdbc:postgresql://$Endpoint/$Database")
      .option("dbtable", Table)
      .option("user", User)
      .option("password", Password)
      .option("driver", "org.postgresql.Driver")
      .load())

    val movieReview = (spark.read
      .format("csv")
      .option("header", "true")
      .load(MovieRevPath))

    val logReviews = (spark.read
      .format("csv")
      .option("header", "true")
      .load(LogRevPath))

    // Transform

    // Simply create view
    userPurchase.createOrReplaceTempView("user_purchase")

    // Classify comments by sentiment
    val movieReviewTransformed =
      Logics.movieReviewLogicHasGood(movieReview, spark)
    movieReviewTransformed.createOrReplaceTempView("movie_review")

    // Parse XML content content into columns
    val logReviewsTransformed = Logics.logReviewsLogic(logReviews, spark)
    logReviewsTransformed.createOrReplaceTempView("log_reviews")

    // Create fact table
    val factMovieAnalytics = spark.sql("""
      SELECT
        row_number() over (order by lr.log_date) as id_fact_movie_analytics,
        lr.log_date as id_dim_date,
        case lr.location
          WHEN 'Alabama' THEN 'AL'
          WHEN 'Alaska' THEN 'AK'
          WHEN 'Arizona' THEN 'AZ'
          WHEN 'Arkansas' THEN 'AR'
          WHEN 'California' THEN 'CA'
          WHEN 'Colorado' THEN 'CO'
          WHEN 'Connecticut' THEN 'CT'
          WHEN 'Delaware' THEN 'DE'
          WHEN 'Florida' THEN 'FL'
          WHEN 'Georgia' THEN 'GA'
          WHEN 'Hawaii' THEN 'HI'
          WHEN 'Idaho' THEN 'ID'
          WHEN 'Illinois' THEN 'IL'
          WHEN 'Indiana' THEN 'IN'
          WHEN 'Iowa' THEN 'IA'
          WHEN 'Kansas' THEN 'KS'
          WHEN 'Kentucky' THEN 'KY'
          WHEN 'Lousiana' THEN 'LA'
          WHEN 'Maine' THEN 'ME'
          WHEN 'Maryland' THEN 'MD'
          WHEN 'Massachussets' THEN 'MA'
          WHEN 'Michigan' THEN 'MI'
          WHEN 'Minnesota' THEN 'MN'
          WHEN 'Mississippi' THEN 'MS'
          WHEN 'Missouri' THEN 'MO'
          WHEN 'Montana' THEN 'MT'
          WHEN 'Nebraska' THEN 'NE'
          WHEN 'Nevada' THEN 'NV'
          WHEN 'New Hampshire' THEN 'NH'
          WHEN 'New Jersey' THEN 'NJ'
          WHEN 'New Mexico' THEN 'NM'
          WHEN 'New York' THEN 'NY'
          WHEN 'North Carolina' THEN 'NC'
          WHEN 'North Dakota' THEN 'ND'
          WHEN 'Ohio' THEN 'OH'
          WHEN 'Oklahoma' THEN 'OK'
          WHEN 'Oregon' THEN 'OR'
          WHEN 'Pensylvania' THEN 'PA'
          WHEN 'Rhode Island' THEN 'RI'
          WHEN 'South Carolina' THEN 'SC'
          WHEN 'South Dakota' THEN 'SD'
          WHEN 'Tennessee' THEN 'TN'
          WHEN 'Texas' THEN 'TX'
          WHEN 'Utah' THEN 'UT'
          WHEN 'Vermont' THEN 'VT'
          WHEN 'Virginia' THEN 'VA'
          WHEN 'Washington' THEN 'WA'
          WHEN 'West Virginia' THEN 'WV'
          WHEN 'Wisconsin' THEN 'WI'
          WHEN 'Wyoming' THEN 'WY'
        end as id_dim_location,
        concat( 
          case lr.device 
            when 'Mobile' then 'M'
            when 'Computer' then 'C'
            when 'Tablet' then 'T'
          end,
          '_',
          case lr.os
            when 'Apple iOS' then 'I'
            when 'Linux' then 'L'
            when 'Apple MacOS' then 'M'
            when 'Google Android' then 'A'
            when 'Microsoft Windows' then 'W'
          end,
          '_',
          case lr.browser
            when 'chrome' then 'C'
            when 'edge' then 'E'
            when 'firefox' then 'F'
            when 'safari' then 'S'
          end
        ) as id_dim_device,
        SUM(up.quantity * up.unit_price) as amount_spent,
        SUM(mr.positive_review) as review_score, 
        COUNT(mr.review_id) as review_count
      FROM
        user_purchase up
      INNER JOIN 
        movie_review mr ON up.customer_id = mr.customer_id
      INNER JOIN 
        log_reviews lr ON mr.review_id = lr.log_id
      GROUP BY
        lr.log_date,
        lr.location,
        lr.device,
        lr.os,
        lr.browser
    """)

    // Load

    userPurchase.write
      .mode("overwrite")
      .parquet(s"$StagingPath/user_purchase_parq")

    movieReviewTransformed.write
      .mode("overwrite")
      .parquet(s"$StagingPath/movie_review_parq")

    logReviewsTransformed.write
      .mode("overwrite")
      .parquet(s"$StagingPath/log_reviews_parq")

    factMovieAnalytics
      .write
      .partitionBy("id_dim_location")
      .mode("overwrite")
      .parquet(s"$StagingPath/fact_movie_analytics_parq")

    Job.commit()
    spark.stop()
  }
}
