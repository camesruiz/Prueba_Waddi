# Glue role

resource "aws_iam_policy" "glue_policy" {
  name        = "glue_policy"
  description = "Glue"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
      Effect: "Allow"
      Action: [
        "glue:*"
      ]
      Resource: "*"
    },
      {
      Effect   = "Allow"
      Action   = [
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = [
        "arn:aws:s3:::*/*"
      ]
    },
      {
      Effect: "Allow"
      Action: [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource: "arn:aws:logs:*:*:*"
    },
      {
      Effect: "Allow"
      Action: [
        "iam:PassRole"
      ]
      Resource: "*"
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
  policy_arn = aws_iam_policy.glue_policy.arn
}

# Lambda role

resource "aws_iam_policy" "s3_policy" {
  name        = "S3_policy"
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

resource "aws_iam_role" "s3_role" {
  name = "s3_waddi_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_lambda_access_attachment" {
  role       = aws_iam_role.s3_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

# sfn role

resource "aws_iam_policy" "lambda_invoke_policy" {
  name        = "waddi_lambda_invoke_policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": [
                "arn:aws:lambda:us-east-1:339712764304:function:waddi_data_ingestion:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": [
                "arn:aws:lambda:us-east-1:339712764304:function:waddi_data_ingestion"
            ]
        }
    ]
})
}

resource "aws_iam_policy" "glue_start_policy" {
  name        = "waddi_glue_policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "glue:StartJobRun"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
})
}

resource "aws_iam_policy" "xray_policy" {
  name        = "waddi_xray_policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords",
                "xray:GetSamplingRules",
                "xray:GetSamplingTargets"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
})
}

resource "aws_iam_role" "waddi_sfn_role" {
  name = "sfn_waddi_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "states.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
})
}

resource "aws_iam_role_policy_attachment" "sfn_lambda_attachment" {
  role       = aws_iam_role.waddi_sfn_role.name
  policy_arn = aws_iam_policy.lambda_invoke_policy.arn
}

resource "aws_iam_role_policy_attachment" "sfn_glue_attachment" {
  role       = aws_iam_role.waddi_sfn_role.name
  policy_arn = aws_iam_policy.glue_start_policy.arn
}

resource "aws_iam_role_policy_attachment" "sfn_xray_attachment" {
  role       = aws_iam_role.waddi_sfn_role.name
  policy_arn = aws_iam_policy.xray_policy.arn
}