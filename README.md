# AWS Redshift Analytics Platform

## Overview
Scalable data warehouse for high-volume transactional analytics using AWS Redshift, S3, and Glue.

## Technologies 
- AWS Redshift (dc2.large nodes)
- Amazon S3
- AWS Glue
- Terraform 0.12
- Python 3.9+

## Architecture
- Data Lake: S3
- ETL: AWS Glue
- Data Warehouse: Redshift
- Orchestration: AWS Step Functions

## Project Structure
```
├── terraform/          # Infrastructure as Code
├── sql/               # SQL scripts
├── glue/              # Glue ETL jobs
└── scripts/           # Utility scripts
```

## Deployment

### Prerequisites
- AWS CLI configured
- Terraform installed

### Deploy Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Create Tables
```bash
psql -h <redshift-endpoint> -U admin -d analytics -f sql/create_tables.sql
```

## Features
- Multi-node cluster configuration
- S3 data lake integration
- Automated ETL with Glue
- Columnar storage with compression
- Distribution and sort keys optimization
- VPC security
