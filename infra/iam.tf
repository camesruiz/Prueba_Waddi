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