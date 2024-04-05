resource "aws_lambda_function" "lambda-function" {
  function_name = "waddi_data_ingestion"
  role          = aws_iam_role.s3_role.arn
  s3_bucket     = aws_s3_bucket.data-bucket.bucket
  s3_key        = "${aws_s3_object.lambda-folder.key}lambda_function.zip"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  timeout       = 601
  memory_size   = 512
}
