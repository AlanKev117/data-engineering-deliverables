resource "aws_glue_connection" "gc_to_rds" {
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:${var.gc_db_type}://${var.gc_db_endpoint}/${var.gc_db_name}"
    PASSWORD            = var.gc_db_password
    USERNAME            = var.gc_db_username
  }

  name = "gc_to_rds"

  physical_connection_requirements {
    availability_zone      = var.gc_subnet_az
    security_group_id_list = [var.gc_secgroup_id]
    subnet_id              = var.gc_subnet_id
  }
}

resource "aws_iam_role" "glue_iam_role" {
  name = "AWSGlueServiceRoleTF"
  assume_role_policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "glue.amazonaws.com"
        },
        "Action" = "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  ]
}

resource "aws_glue_job" "transform" {
  name     = "transform"
  role_arn = aws_iam_role.glue_iam_role.arn

  command {
    script_location = "s3://${var.gj_bucket_id}/${var.gj_job_id}"
  }

  glue_version = "3.0"

  max_retries = 0
  timeout     = 15

  connections = [aws_glue_connection.gc_to_rds.name]

  worker_type       = "G.1X"
  number_of_workers = 4

  default_arguments = {
    "--job-language" = "scala"
    "--class"        = "${var.gj_class}"
  }
}
