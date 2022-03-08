// import com.amazonaws.services.glue.{GlueContext, DynamicRecord, DynamicFrame}
// import com.amazonaws.services.glue.util.{Job, GlueArgParser, JsonOptions}
// import com.amazonaws.services.glue.types._
// import org.apache.spark.SparkContext
// import org.apache.spark.sql.{DataFrame, Row, SparkSession}
// import org.apache.spark.sql.functions._
// import edu.stanford.nlp.ling.CoreAnnotations
// import edu.stanford.nlp.neural.rnn.RNNCoreAnnotations
// import edu.stanford.nlp.pipeline.{Annotation, StanfordCoreNLP}
// import edu.stanford.nlp.sentiment.SentimentCoreAnnotations
// import com.databricks.spark.corenlp.functions._
// import java.util.Properties
// import scala.collection.convert.wrapAll._
// import scala.collection.JavaConverters._

// object MyNLP {
//   val props = new Properties()
//   props.setProperty(
//     "annotators",
//     "tokenize, cleanxml, ssplit, parse, sentiment"
//   )
//   props.setProperty("parse.maxlen", "1500")

//   lazy val coreNLP = new StanfordCoreNLP(props)

//   def estimatedSentiment(text: String): Int = {
//     if ((text == null) || (!text.nonEmpty)) { return 0 }
//     val annotations = MyNLP.coreNLP.process(text)
//     val sentences =
//       annotations.get(classOf[CoreAnnotations.SentencesAnnotation])
//     val finalScore = sentences.foldLeft(0.0)((csum, x) => {
//       csum + RNNCoreAnnotations.getPredictedClass(
//         x.get(classOf[SentimentCoreAnnotations.SentimentAnnotatedTree])
//       )
//     }) / sentences.length
//     if (finalScore > 1.5) 1 else 0
//   }

// }

// object Logics {

//   def movieReviewLogicHasGood(
//       movieReview: DataFrame,
//       spark: SparkSession
//   ): DataFrame = {

//     // Syntax sugar and data type conversions.
//     import spark.implicits._

//     // Transformation using word matching.
//     val hasGoodUdf = udf { (rev: String) => if (rev.contains("good")) 1 else 0 }
//     movieReview
//       .toDF("user_id", "review_str", "review_id")
//       .na
//       .drop()
//       .select(
//         'user_id,
//         hasGoodUdf('review_str).as('positive_review),
//         'review_id
//       )
//   }

//   def movieReviewLogicNlpDynamicFrame(
//       movieReview: DynamicFrame
//   ): DataFrame = {

//     movieReview
//       .applyMapping(
//         Seq(
//           ("cid", "string", "user_id", "string"),
//           ("review_str", "string", "review_str", "string"),
//           ("id_review", "string", "review_id", "string")
//         )
//       )
//       .dropNulls()
//       .map((rec: DynamicRecord) => {
//         val review = rec.getField("review_str")
//         review match {
//           case Some(rev_str: String) => {
//             rec.addField(
//               "positive_review",
//               ScalarNode(
//                 MyNLP.estimatedSentiment(
//                   rev_str.replaceAll("[^\\x00-\\x7F]", "")
//                 )
//               )
//             )
//             rec
//           }
//           case _ => rec
//         }
//       })
//       .selectFields(Seq("user_id", "positive_review", "review_id"))
//       .toDF()
//   }

//   def movieReviewLogicNlpDataFrame(
//       movieReview: DataFrame,
//       spark: SparkSession
//   ): DataFrame = {

//     // For implicit data type conversions
//     import spark.implicits._

//     // Preprocess review before sentiment analysis
//     val cleanCommentUdf = udf { (comment: String) =>
//       comment
//         .slice(0, 70) // shrink review length
//         .replaceAll("[^\\x00-\\x7F]", "") // remove non ascii
//     // .replaceAll("\\<.*?\\>", "") // remove xml
//     }

//     // UDF to transform from 0 - 4 sentiment range to 0 | 1 boolean polarity
//     val isPositiveUdf = udf { (rs: Double) => if (rs > 1.5) 1 else 0 }

//     // Apply transformation with UDFs
//     movieReview
//       .toDF("user_id", "review_str", "review_id")
//       .na
//       .drop()
//       .select(
//         'user_id,
//         isPositiveUdf(
//           sentiment(
//             cleanCommentUdf('review_str)
//           )
//         ).as('positive_review),
//         'review_id
//       )
//   }

//   def logReviewsLogic(
//       logReviews: DataFrame,
//       spark: SparkSession
//   ): DataFrame = {

//     val osToBrowser = Map(
//       "apple ios" -> "safari",
//       "apple macos" -> "safari",
//       "google android" -> "chrome",
//       "linux" -> "firefox",
//       "microsoft windows" -> "edge"
//     )

//     // Create UDF to map OS property to browser.
//     val osToBrowserUdf = udf { (os: String) =>
//       osToBrowser.getOrElse(os.toLowerCase, "chrome")
//     }

//     // Enable DF to be used in Spark SQL sentences.
//     logReviews.na.drop().createOrReplaceTempView("log_reviews")

//     // Apply transformation to DF using Spark SQL string.
//     spark
//       .sql("""
//         SELECT
//           id_review AS log_id,
//           xpath_string(log, '//logDate') AS log_date,
//           xpath_string(log, '//device') AS device,
//           xpath_string(log, '//location') AS location,
//           xpath_string(log, '//os') AS os,
//           xpath_string(log, '//ipAddress') AS ip,
//           xpath_string(log, '//phoneNumber') AS phone_number
//         FROM
//           log_reviews
//       """)
//       .withColumn("browser", osToBrowserUdf(col("os")))
//       .select(
//         "log_id",
//         "log_date",
//         "device",
//         "os",
//         "location",
//         "browser",
//         "ip",
//         "phone_number"
//       )
//   }
// }

// object Sentiment {

//   def main(sysArgs: Array[String]) = {
//     // Instanciate Glue's Spark Session
//     val sc: SparkContext = SparkContext.getOrCreate()
//     val glueContext: GlueContext = new GlueContext(sc)
//     val spark: SparkSession = glueContext.getSparkSession

//     // Parse script args.
//     val params = Seq(
//       "JOB_NAME",
//       "db_endpoint",
//       "db_name",
//       "db_table",
//       "db_user",
//       "db_password",
//       "movie_rev_path",
//       "log_rev_path",
//       "staging_path"
//     )

//     val args =
//       GlueArgParser.getResolvedOptions(sysArgs, params.toArray)
//     Job.init(args("JOB_NAME"), glueContext, args.asJava)

//     val Endpoint = args("db_endpoint")
//     val Database = args("db_database")
//     val Table = args("db_table")
//     val User = args("db_user")
//     val Password = args("db_password")
//     val MovieRevPath = args("movie_rev_path")
//     val LogRevPath = args("log_rev_path")
//     val StagingPath = args("staging_path")

//     // Extract data from raw area

//     val userPurchase = (spark.read
//       .format("jdbc")
//       .option("url", s"jdbc:postgresql://$Endpoint/$Database")
//       .option("dbtable", Table)
//       .option("user", User)
//       .option("password", Password)
//       .option("driver", "org.postgresql.Driver")
//       .load())

//     val movieReview = (spark.read
//       .format("csv")
//       .option("header", "true")
//       .load(MovieRevPath))
//     // val movieReview = (glueContext
//     //   .getSourceWithFormat(
//     //     connectionType = if (StagingPath.startsWith("s3")) "s3" else "file",
//     //     options = JsonOptions(
//     //       s"""{"paths": ["$MovieRevPath"], "recurse": true, "groupFiles": "inPartition"}"""
//     //     ),
//     //     format = "csv",
//     //     formatOptions =
//     //       JsonOptions(s"""{"withHeader":"true","separator": ","}""")
//     //   )
//     //   .getDynamicFrame)

//     val logReviews = (spark.read
//       .format("csv")
//       .option("header", "true")
//       .load(LogRevPath))

//     // ---------- Transform dataframes

//     // 1. movie reviews
//     val movieReviewTransformed =
//       Logics.movieReviewLogicHasGood(movieReview, spark)
//     // val movieReviewTransformed =
//     //   Logics.movieReviewLogicNlpDataFrame(movieReview, spark)
//     // val movieReviewTransformed =
//     //   Logics.movieReviewLogicNlpDynamicFrame(movieReview)

//     // 2. log reviews
//     val logReviewsTransformed = Logics.logReviewsLogic(logReviews, spark)

//     // ---------- Load data to staging

//     userPurchase.write
//       .mode("overwrite")
//       .parquet(s"$StagingPath/user_purchase_parq")

//     movieReviewTransformed.write
//       .mode("overwrite")
//       .parquet(s"$StagingPath/movie_review_parq")

//     // glueContext
//     //   .getSinkWithFormat(
//     //     connectionType = if (StagingPath.startsWith("s3")) "s3" else "file",
//     //     options = JsonOptions(
//     //       s"""{"paths": ["$StagingPath"]}"""
//     //     ),
//     //     format = "parquet"
//     //   )
//     //   .writeDynamicFrame(movieReviewTransformed)

//     logReviewsTransformed.write
//       .mode("overwrite")
//       .parquet(s"$StagingPath/log_reviews_parq")

//     Job.commit()
//     spark.stop()
//   }
// }
