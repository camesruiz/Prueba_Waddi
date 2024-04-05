resource "aws_s3_bucket" "data-bucket" {
    bucket = "camesruiz-waddi"
}

resource "aws_s3_object" "glue-folder" {
    bucket = aws_s3_bucket.data-bucket.id
    key    = "glue_script/"
}

resource "aws_s3_object" "lambda-folder" {
    bucket = aws_s3_bucket.data-bucket.id
    key    = "lambda_script/"
}

resource "aws_s3_object" "data-folder" {
    bucket = aws_s3_bucket.data-bucket.id
    key    = "data/"
}
