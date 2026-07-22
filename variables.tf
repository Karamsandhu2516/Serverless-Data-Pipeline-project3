variable "aws_region" {
    type = string
    description = "AWS region"
    default = "us-east-1"
}

variable "s3_bucket_name" {
    type = string
    description = "Name of the S3 bucket"
    default = "project3-bucket"
}

variable "s3_bucket_versioning" {
    type = bool
    description = "Enable versioning for the S3 bucket"
    default = true
}

variable "dynamodb_table_name" {
    type = string
    description = "Name of the DynamoDB table"
    default = "project3-table"
}   

variable "lambda_function_name" {
    type = string
    description = "Name of the lambda function"
    default = "project3-lambda"
}       

variable "sqs_queue_name" {
  type        = string
  description = "Name of the SQS Dead Letter Queue"
  default     = "project3-dlq"
}