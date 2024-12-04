variable "qa_bucket_name" {
  description = "Name of the source S3 bucket"
  type        = string
}

variable "prd_bucket_name" {
  description = "Name of the destination S3 bucket"
  type        = string
}

variable "qa_replication_role_name" {
  description = "Name for the replication IAM role"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID for bucket replication policy"
  type        = string
}

variable "app_env" {
  description = "QA Environment"
  type        = string
}