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
    Internet((🌐 Internet)):::user --> IGW

    subgraph VPC ["VPC"]
        IGW["🚪 Internet Gateway (IGW)"]:::igw

        IGW --> ALB["⚖️ Application Load Balancer (ALB)"]:::alb
        
        subgraph AZ1 ["AZ-1"]
            subgraph PubSub1 ["Public Subnet (10.0.1.0/24)"]
                NAT["🔄 NAT Gateway"]:::nat
            end
            subgraph PrivApp1 ["Private App Subnet (10.0.11.0/24)"]
                EC2_1["💻 EC2 Instance"]:::ec2
            end
            subgraph PrivData1 ["Private Data Subnet (10.0.21.0/24)"]
                RDS_1["🗄️ RDS MySQL (Primary)"]:::rds
            end
        end

        subgraph AZ2 ["AZ-2"]
            subgraph PubSub2 ["Public Subnet (10.0.2.0/24)"]
                Placeholder[" "]:::hidden
            end
            subgraph PrivApp2 ["Private App Subnet (10.0.12.0/24)"]
                EC2_2["💻 EC2 Instance"]:::ec2
            end
            subgraph PrivData2 ["Private Data Subnet (10.0.22.0/24)"]
                RDS_2["🗄️ RDS MySQL (Standby/Replica)"]:::rds
            end
        end

        %% Auto Scaling Group Note
        ASG_NOTE>Auto Scaling Group]:::asg_note
    end

    %% Connections
    ALB --> EC2_1
    ALB --> EC2_2
    EC2_1 -.-> NAT
    NAT -.-> IGW
    EC2_1 --> RDS_1
    EC2_2 --> RDS_2
    RDS_1 -.->|Replication| RDS_2
    
    EC2_1 -.- ASG_NOTE
    EC2_2 -.- ASG_NOTE

    %% Styles
    classDef user fill:#2c2c2c,stroke:#ffffff,stroke-width:2px,color:#fff;
    classDef igw fill:#652b47,stroke:#c4476d,stroke-width:2px,color:#fff;
    classDef alb fill:#753151,stroke:#e5457a,stroke-width:2px,color:#fff;
    classDef nat fill:#753151,stroke:#e5457a,stroke-width:2px,color:#fff;
    classDef ec2 fill:#854b2a,stroke:#d86613,stroke-width:2px,color:#fff;
    classDef rds fill:#264a85,stroke:#4481eb,stroke-width:2px,color:#fff;
    classDef hidden fill:none,stroke:none,color:none;
    classDef asg_note fill:none,stroke:#d86613,stroke-width:2px,stroke-dasharray: 5 5,color:#d86613;

    style VPC fill:#141414,stroke:#333,stroke-width:2px,color:#aaa;
    style AZ1 fill:none,stroke:#333,stroke-width:1px,stroke-dasharray: 5 5;
    style AZ2 fill:none,stroke:#333,stroke-width:1px,stroke-dasharray: 5 5;
    style PubSub1 fill:#1a2b1f,stroke:#2d5c39,stroke-width:1px;
    style PubSub2 fill:#1a2b1f,stroke:#2d5c39,stroke-width:1px;
    style PrivApp1 fill:#1a202c,stroke:#2b4365,stroke-width:1px;
    style PrivApp2 fill:#1a202c,stroke:#2b4365,stroke-width:1px;
    style PrivData1 fill:#1a202c,stroke:#2b4365,stroke-width:1px;
    style PrivData2 fill:#1a202c,stroke:#2b4365,stroke-width:1px;
```


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
