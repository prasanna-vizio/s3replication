provider "aws" {
  region = var.region
}

module "s3_replication" {
  source                 = "./s3_replication"
  source_bucket_name     = var.source_bucket_name
  destination_bucket_name = var.destination_bucket_name
  replication_role_name  = var.replication_role_name
  aws_account_id         = var.aws_account_id
}

output "source_bucket_id" {
  value = module.s3_replication.source_bucket_id
}

output "destination_bucket_id" {
  value = module.s3_replication.destination_bucket_id
}

output "replication_role_arn" {
  value = module.s3_replication.replication_role_arn
}
