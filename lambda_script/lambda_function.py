import json
import boto3
import csv


def lambda_handler(event, context):
    # Initialize S3 clients
    s3_client = boto3.client('s3')

    # Get the source bucket and key from the event
    bucket = event['Records'][0]['s3']['bucket']['name']
    source_key = event['Records'][0]['s3']['object']['key']

    output_key = source_key.replace('.csv', '.json')  # Change the file extension to .json

    # Read CSV file from S3
    response = s3_client.get_object(Bucket=bucket, Key=source_key)
    csv_data = response['Body'].read().decode('utf-8').splitlines()

    # Convert CSV to JSON
    csv_reader = csv.DictReader(csv_data)
    json_data = json.dumps(list(csv_reader))

    # Upload JSON file to S3
    s3_client.put_object(Bucket=bucket, Key=output_key, Body=json_data)

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'CSV file converted to JSON and uploaded successfully'})
    }
