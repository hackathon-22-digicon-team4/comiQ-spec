resource "aws_s3_bucket" "comiq_prod" {
  bucket = "comiq-prod-assets"
}

resource "aws_s3_bucket_versioning" "comiq_prod_versioning" {
  bucket = aws_s3_bucket.comiq_prod.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "comiq_prod_acl" {
  bucket = aws_s3_bucket.comiq_prod.id
  acl    = "private"
}