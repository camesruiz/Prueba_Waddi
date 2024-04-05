import unittest
import os
import sys
import json

parent_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.append(parent_dir)

from lambda_script.lambda_function import lambda_handler


class TestLambdaFunction(unittest.TestCase):
    def test_lambda_handler(self):

        event = {
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
            }

        # Call the Lambda handler function
        result = lambda_handler(event, None)

        # Check if the function returns the expected result
        self.assertEqual(result['statusCode'], 200)
        self.assertIn('message', json.loads(result['body']))
        self.assertEqual(json.loads(result['body'])['message'], 'CSV file converted to JSON and uploaded successfully')


if __name__ == '__main__':
    unittest.main()
