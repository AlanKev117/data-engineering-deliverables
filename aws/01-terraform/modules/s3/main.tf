resource "aws_s3_bucket" "bucket" {
  bucket_prefix = var.bucket_prefix

  versioning {
    enabled = var.versioning
  }

  tags = {
    Name = "s3-data-bootcamp"
  }
}

resource "aws_s3_bucket_object" "csv_user_purchase" {
  bucket = aws_s3_bucket.bucket.id
  key    = "user_purchase.csv"
  source = var.csv_user_purchase_path
}