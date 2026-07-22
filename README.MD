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

## 🏗️ Architecture Diagram

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': { 'primaryColor': '#1e1e1e', 'primaryTextColor': '#fff', 'primaryBorderColor': '#ff9900', 'lineColor': '#8a94a6', 'fontFamily': 'Inter, sans-serif'}}}%%
graph TD
    classDef s3 fill:#3b593f,stroke:#66a54f,stroke-width:2px,color:#fff;
    classDef lambda fill:#854b2a,stroke:#d86613,stroke-width:2px,color:#fff;
    classDef ddb fill:#264a85,stroke:#4481eb,stroke-width:2px,color:#fff;
    classDef sqs fill:#753151,stroke:#e5457a,stroke-width:2px,color:#fff;
    classDef cw fill:#652b47,stroke:#c4476d,stroke-width:2px,color:#fff;
    classDef user fill:#2c2c2c,stroke:#ffffff,stroke-width:2px,color:#fff;

    Client((User / System)):::user -->|Uploads JSON File| S3[("Amazon S3<br>(Ingestion Bucket)")]:::s3
    
    subgraph "AWS Serverless Infrastructure"
        S3 -->|S3 Event Notification| L(fa:fa-bolt AWS Lambda<br>Data Processor):::lambda
        L -->|PutItem (Valid Records)| DB[("Amazon DynamoDB<br>(Transactions Table)")]:::ddb
        L -.->|Send Message (Failures)| DLQ>Amazon SQS<br>Dead Letter Queue]:::sqs
        L -.->|Metric: Errors > 0| CW(("Amazon CloudWatch<br>Alarm")):::cw
        CW -.->|Publish Notification| SNS[{"Amazon SNS<br>Topic"}]:::cw
    end
    
    style AWS Serverless Infrastructure fill:#141414,stroke:#333,stroke-width:1px,stroke-dasharray: 5 5,color:#aaa;
```

> **Note:** The diagram above is rendered using Mermaid JS. For a highly stylized visual like the reference image (with glowing paths and official AWS 3D isometric icons), you can import this architecture into tools like [Draw.io (AWS Dark Theme)](https://app.diagrams.net/), [Lucidchart](https://www.lucidchart.com/), or [Brainboard](https://www.brainboard.co/).

---

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

---

## 🧹 Cleanup

To tear down the infrastructure and avoid incurring future AWS charges:

```bash
terraform destroy
```

<div align="center">
  <i>Built with ❤️ using Terraform & AWS</i>
</div>
