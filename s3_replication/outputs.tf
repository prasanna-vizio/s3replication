output "qa_bucket_id" {
  description = "ID of the source S3 bucket"
  value       = aws_s3_bucket.qa_bucket.id
}

output "prd_bucket_id" {
  description = "ID of the destination S3 bucket"
  value       = aws_s3_bucket.prd_bucket.id
}

output "replication_role_arn" {
  description = "ARN of the replication IAM role"
  value       = aws_iam_role.qa_bucket_role.arn
}