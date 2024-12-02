output "source_bucket_id" {
  description = "ID of the source S3 bucket"
  value       = aws_s3_bucket.source_bucket.id
}

output "destination_bucket_id" {
  description = "ID of the destination S3 bucket"
  value       = aws_s3_bucket.destination_bucket.id
}

output "replication_role_arn" {
  description = "ARN of the replication IAM role"
  value       = aws_iam_role.replication_role.arn
}