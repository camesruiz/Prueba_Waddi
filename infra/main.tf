provider "aws" {
  region = "us-east-1"
  profile = "default"
}

#S3 bucket
resource "aws_s3_bucket" "data-bucket" {
    bucket = "camesruiz-waddi"
}

resource "aws_s3_object" "glue-folder" {
    bucket = "${aws_s3_bucket.data-bucket.id}"
    key    = "glue_script/"
}

resource "aws_s3_object" "lambda-folder" {
    bucket = "${aws_s3_bucket.data-bucket.id}"
    key    = "lambda_script/"
}

resource "aws_s3_object" "data-folder" {
    bucket = "${aws_s3_bucket.data-bucket.id}"
    key    = "data/"
}

#IAM Role S3
resource "aws_iam_policy" "s3_policy" {
  name        = "S3_access"
  description = "Access to S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = [
        "arn:aws:s3:::*/*"
      ]
    }]
  })
}

resource "aws_iam_role" "glue_role" {
  name = "glue_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "glue.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}