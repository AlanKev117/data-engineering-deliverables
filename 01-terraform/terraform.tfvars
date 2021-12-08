# VPC / etc.
project_id = "data-engineering-af"
region     = "us-central1"
location   = "us-central1-a"

#GKE
gke_num_nodes = 2
machine_type  = "n1-standard-2"

#CloudSQL
database_version = "POSTGRES_12"
instance_tier    = "db-f1-micro"
disk_space       = 10
database_name    = "ods"
db_username      = "mover"

# Dataproc cluster
dp_cluster_workers = 2
dp_cluster_machine_type = "n1-standard-2"

# Buckets
raw_bucket_name = "raw-bucket-de-af"
staging_bucket_name = "staging-bucket-de-af"
spark_job_path = "resources/job.py"
user_purchase_path = "resources/user_purchase.csv"
movie_review_path = "resources/movie_review.csv"

# BigQuery
bq_dataset_id = "insights_de_af"
