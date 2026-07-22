resource "aws_s3_bucket" "demo-bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "project3-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "demo-versioning" {
  bucket = aws_s3_bucket.demo-bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}  

resource "aws_dynamodb_table" "demo-table" {
  name = var.dynamodb_table_name   
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "transaction_id"
  attribute {
    name = "transaction_id"
    type = "S"
  }
  attribute {
    name = "timestamp"
    type = "S"
  } 
  global_secondary_index {
    name            = "TimestampIndex"
    hash_key        = "timestamp"
    projection_type = "ALL"
  }
}   


data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/lambda/lambda_function.zip"
}


resource "aws_lambda_function" "demo-lambda" {
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.9"
  handler          = "index.lambda_handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  dead_letter_config {
    target_arn = aws_sqs_queue.demo-queue.arn
  }
}

resource "aws_sqs_queue" "demo-queue" {
    name = "project3-queue"
}

resource "aws_iam_role" "lambda_role" {
    name = "lambda_role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Effect": "Allow",
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # CloudWatch Logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      # S3 Access
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.demo-bucket.arn}/*"
      },
      # DynamoDB Access
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = [
          aws_dynamodb_table.demo-table.arn,
          "${aws_dynamodb_table.demo-table.arn}/*"
        ]
      },
      # SQS DLQ Access
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = aws_sqs_queue.demo-queue.arn
      }
    ]
  })
}

resource "aws_lambda_permission" "allow_s3_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.demo-lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.demo-bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.demo-bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.demo-lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_bucket]
}

resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "lambda-error-rate-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggers when Lambda produces errors"

  dimensions = {
    FunctionName = aws_lambda_function.demo-lambda.function_name
  }

  alarm_actions = [aws_sns_topic.demo-topic.arn]
}    

resource "aws_sns_topic" "demo-topic" {
  name = "project3-topic"
}