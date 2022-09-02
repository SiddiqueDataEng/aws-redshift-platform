variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_identifier" {
  description = "Redshift cluster identifier"
  type        = string
  default     = "analytics-cluster"
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "analytics"
}

variable "master_username" {
  description = "Master username"
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "node_type" {
  description = "Node type"
  type        = string
  default     = "dc2.large"
}

variable "cluster_type" {
  description = "Cluster type"
  type        = string
  default     = "multi-node"
}

variable "number_of_nodes" {
  description = "Number of nodes"
  type        = number
  default     = 2
}

variable "s3_bucket_name" {
  description = "S3 bucket name for data lake"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "Allowed CIDR blocks for Redshift access"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
