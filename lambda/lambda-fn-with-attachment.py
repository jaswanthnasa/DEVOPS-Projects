import os
import boto3
from botocore.exceptions import ClientError
import logging
import json
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
import smtplib

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize S3 and SES clients
s3_client = boto3.client('s3')
ses_client = boto3.client('ses')

def lambda_handler(event, context):
    # Get the bucket and object key from the S3 event notification
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    print(bucket)

    # Temporarily download the file to Lambda's /tmp directory
    download_path = '/tmp/{}'.format(os.path.basename(key))
    s3_client.download_file(bucket, key, download_path)

    # Email parameters
    sender = 'jassu.563@gmail.com'
    recipient = 'jassu.563@gmail.com'
    subject = 'File from S3 Bucket'
    body_text = 'Please find the attached file from S3.'

    # Create a MIME multipart message
    msg = MIMEMultipart()
    msg['Subject'] = subject
    msg['From'] = sender
    msg['To'] = recipient
    msg.attach(MIMEText(body_text))

    # Attach the file to the email
    attachment = MIMEApplication(open(download_path, 'rb').read())
    attachment.add_header('Content-Disposition', 'attachment', filename=os.path.basename(download_path))
    msg.attach(attachment)

    # Send the email
    try:
        response = ses_client.send_raw_email(
            Source=sender,
            Destinations=[recipient],
            RawMessage={'Data': msg.as_string()}
        )
        logger.info("Email sent successfully: {}".format(response['MessageId']))
    except ClientError as e:
        logger.error("Error sending email: {}".format(e.response['Error']['Message']))
        raise

    # Clean up: Delete the downloaded file from /tmp
    os.remove(download_path)
