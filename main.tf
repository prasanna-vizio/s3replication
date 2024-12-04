provider "aws" {
  region = var.region
}

module "s3_replication_qa" {
  count = var.app_env == "qa" ? 1 : 0
  source                 = "./s3_replication_qa"
  qa_bucket_name = var.qa_bucket_name
  qa_replication_role_name = var.qa_replication_role_name
  prd_bucket_name = var.prd_bucket_name
  aws_account_id         = var.aws_account_id
  app_env = var.app_env
}

module "s3_replication_prd" {
  count = var.app_env == "qa" ? 1 : 0
  source                 = "./s3_replication_prd"
  qa_bucket_name = var.qa_bucket_name
  qa_replication_role_name = var.qa_replication_role_name
  prd_bucket_name = var.prd_bucket_name
  aws_account_id         = var.aws_account_id
  app_env = var.app_env
}
