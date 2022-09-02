terraform {
  required_version = ">= 0.12"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC for Redshift
resource "aws_vpc" "redshift_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "redshift-vpc"
  }
}

# Subnet Group
resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = "redshift-subnet-group"
  subnet_ids = aws_subnet.redshift_subnet[*].id

  tags = {
    Name = "redshift-subnet-group"
  }
}

# Subnets
resource "aws_subnet" "redshift_subnet" {
  count             = 2
  vpc_id            = aws_vpc.redshift_vpc.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "redshift-subnet-${count.index + 1}"
  }
}

# Security Group
resource "aws_security_group" "redshift_sg" {
  name        = "redshift-security-group"
  description = "Security group for Redshift cluster"
  vpc_id      = aws_vpc.redshift_vpc.id

  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redshift-sg"
  }
}

# IAM Role for Redshift
resource "aws_iam_role" "redshift_role" {
  name = "redshift-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "redshift_s3_policy" {
  role       = aws_iam_role.redshift_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Redshift Cluster
resource "aws_redshift_cluster" "analytics_cluster" {
  cluster_identifier        = var.cluster_identifier
  database_name            = var.database_name
  master_username          = var.master_username
  master_password          = var.master_password
  node_type                = var.node_type
  cluster_type             = var.cluster_type
  number_of_nodes          = var.number_of_nodes
  
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.redshift_sg.id]
  iam_roles                 = [aws_iam_role.redshift_role.arn]
  
  encrypted                 = true
  enhanced_vpc_routing      = true
  publicly_accessible       = false
  
  skip_final_snapshot       = true

  tags = {
    Name = "analytics-redshift-cluster"
  }
}

# S3 Bucket for Data Lake
resource "aws_s3_bucket" "data_lake" {
  bucket = var.s3_bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "data-lake-bucket"
  }
}

# Glue Database
resource "aws_glue_catalog_database" "analytics_db" {
  name = "analytics_catalog"
}

data "aws_availability_zones" "available" {
  state = "available"
}
