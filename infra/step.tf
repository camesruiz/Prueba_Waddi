resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "waddi-data-pipeline"
  role_arn = aws_iam_role.waddi_sfn_role.arn

  definition = <<EOF
{
  "Comment": "A description of my state machine",
  "StartAt": "Lambda Invoke",
  "States": {
    "Lambda Invoke": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload": {
          "Records": [
            {
              "s3": {
                "bucket": {
                  "name": "camesruiz-waddi"
                },
                "object": {
                  "key": "dataset.csv"
                }
              }
            }
          ]
        },
        "FunctionName": "arn:aws:lambda:us-east-1:339712764304:function:waddi_data_ingestion:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 1,
          "MaxAttempts": 3,
          "BackoffRate": 2
        }
      ],
      "Next": "Glue StartJobRun"
    },
    "Glue StartJobRun": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startJobRun",
      "Parameters": {
        "JobName": "etl_job"
      },
      "End": true
    }
  }
}
EOF
}