provider "aws" {
  region = var.region
}

module "s3_replication" {
  source                 = "./s3_replication"
  qa_bucket_qa_bucket_name = 
  prd_bucket_name = 
  qqa_replication_role_name = 
  aws_account_id         = var.aws_account_id
  app_env = 
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
