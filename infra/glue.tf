resource "aws_s3_object" "etl-script" {
  bucket = aws_s3_bucket.data-bucket.id
  key    = "glue_script/etl.py"
  source = "${local.glue_path}etl.py"
  etag   = filemd5("${local.glue_path}etl.py")
}

resource "aws_glue_job" "etl-job" {
  name     = "etl_job"
  role_arn = aws_iam_role.glue_role.arn
  glue_version = "4.0"
  max_retries = 0
  number_of_workers = 2
  worker_type = "G.1X"
  timeout = "120"
  execution_class = "FLEX"
  command {
    script_location = "s3://${aws_s3_bucket.data-bucket.bucket}/glue_script/etl.py"
  }
  default_arguments = {
    "--class"                   = "GlueApp"
    "--enable-job-insights"     = "true"
    "--enable-auto-scaling"     = "false"
    "--enable-glue-datacatalog" = "true"
    "--encryption-type"         = "sse-s3"
    "--TempDir"                 = "s3://${aws_s3_bucket.data-bucket.bucket}/tmp/"
    "--job-language"            = "python"
    "--job-bookmark-option"     = "job-bookmark-disable"
    # parameters
    "--bucket"                  = aws_s3_bucket.data-bucket.bucket
    "--output_key"              = aws_s3_object.data-folder.key
  }
}

resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = "waddi"
}