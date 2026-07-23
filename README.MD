<div align="center">
  <img src="https://img.shields.io/badge/AWS-Infrastructure-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white" />
  <img src="https://img.shields.io/badge/Terraform-1.x-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" />
  <img src="https://img.shields.io/badge/Python-3.9-3776AB?style=for-the-badge&logo=python&logoColor=white" />
  
  <h1>🌩️ Serverless Data Ingestion Pipeline</h1>
  <p>An automated, event-driven architecture to process S3 uploads and persist transactions to DynamoDB.</p>
</div>

---

## 📖 Overview

This project provisions a robust, serverless infrastructure on AWS using **Terraform**. It automatically ingests JSON transaction data uploaded to an **S3 Bucket**, processes it via an **AWS Lambda** function, and stores valid records into a **DynamoDB** table. The architecture is built with resilience in mind, featuring a Dead-Letter Queue (DLQ) for failed processing and CloudWatch alarms for automated error alerting.

---

## 🏛️ Architecture Diagram

![Serverless Architecture Diagram](images/architecture.png)


## 🚀 Key Components

*   📦 **Amazon S3**: Ingestion point for transaction data files. Versioning is enabled to preserve history.
*   ⚡ **AWS Lambda (Python 3.9)**: Triggered automatically upon file creation. Fetches the JSON file, parses the data, and validates records.
*   🗄️ **Amazon DynamoDB**: NoSQL database provisioned in `PAY_PER_REQUEST` (On-Demand) mode. Stores valid transactions using `transaction_id` as the partition key.
*   🛡️ **Amazon SQS (Dead Letter Queue)**: Captures unprocessable payloads if the Lambda function fails repeatedly, preventing data loss.
*   🔔 **CloudWatch & SNS**: An alarm monitors Lambda execution errors and triggers an SNS notification if failures occur.

---

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed:
1. **Terraform** (v1.0+)
2. **AWS CLI** (Configured with appropriate IAM credentials)
3. **Python 3.9** (Optional, for local testing)

---

## 💻 Deployment Guide

**1. Clone the repository and navigate to the project directory:**
```bash
git clone <your-repo-url>
cd Project3
```

**2. Initialize Terraform:**
Downloads the required AWS provider and prepares the workspace.
```bash
terraform init
```

**3. Preview the infrastructure changes:**
```bash
terraform plan
```

**4. Deploy the infrastructure:**
Confirm the deployment by typing `yes` when prompted.
```bash
terraform apply
```

---

## 🧪 Usage & Testing

1. Once deployed, locate your **S3 Bucket** name from the AWS Console or Terraform output.
2. Create a test `data.json` file:
   ```json
   [
     {
       "transaction_id": "txn-001",
       "timestamp": "2026-07-22T10:00:00Z",
       "amount": 250.00
     }
   ]
   ```
3. Upload the file to S3:
   ```bash
   aws s3 cp data.json s3://<your-bucket-name>/
   ```
4. Navigate to **DynamoDB** in the AWS Console to verify that the record was successfully inserted!
