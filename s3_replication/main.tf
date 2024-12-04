resource "aws_s3_bucket" "qa_bucket" {
  count = var.app_env == "qa" ? 1 : 0
  bucket        = var.qa_bucket_name
 }

 resource "aws_s3_bucket_versioning" "qa_bucket_versioning" {
  depends_on = [ aws_s3_bucket.qa_bucket ]
  bucket = aws_s3_bucket.qa_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "qa_bucket_replication_role" {
  depends_on = [ aws_s3_bucket_versioning.qa_bucket_versioning ]
  name               = var.qa_replication_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowS3ServiceAssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = [
            "s3.amazonaws.com",
            "batchoperations.s3.amazonaws.com" # Added for Batch Operations
          ]
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "qa_bucket_replication_policy" {
  count = var.app_env == "qa" ? 1 : 0
  name   = "${var.qa_bucket_name}-replication-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowFullS3Access"
        Effect = "Allow"
        Action = "s3:*" # All S3 actions
        # Resource = "*"  # All S3 resources
        Resource = "${aws_s3_bucket.qa_bucket.arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "qa_bucket_replication_policy_attachment" {
  count = var.app_env == "qa" ? 1 : 0
  role       = aws_iam_role.qa_bucket_replication_role.name
  policy_arn = aws_iam_policy.qa_bucket_replication_policy.arn
}

resource "aws_s3_bucket_replication_configuration" "qa_bucket_replication_configuration" {
  count = var.app_env == "qa" ? 1 : 0
  bucket = aws_s3_bucket.qa_bucket.id
  depends_on = [ aws_s3_bucket_versioning.qa_bucket_versioning ]
  role = aws_iam_role.qa_bucket_replication_role.arn
    rule {
    id = "ReplicationRule"

    filter {
      prefix = "" # Replicate all objects
    }

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.prd_bucket.arn
      # storage_class = "STANDARD"
    }
    delete_marker_replication {
    status = "Enabled"
    }
  }

}

resource "aws_s3_bucket" "prd_bucket" {
  count = var.app_env == "qa" ? 1 : 0
  bucket        = var.prd_bucket_name
}

resource "aws_s3_bucket_versioning" "prd_bucket_versioning" {
  count = var.app_env == "qa" ? 1 : 0
  bucket = aws_s3_bucket.prd_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "prd_bucket_policy" {
  count = var.app_env == "qa" ? 1 : 0
  bucket = aws_s3_bucket.prd_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
          {
      "Sid": "GrantFullAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.qa_bucket_replication_role.arn}"
      },
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.qa_bucket.arn}",
        "${aws_s3_bucket.qa_bucket.arn}/*"
      ]
    }
      # {
      #   Sid       = "ReplicationPolicy"
      #   Effect    = "Allow"
      #   Principal = {
      #     Service = "s3.amazonaws.com"
      #   }
      #   Action    = "*"
      #    Resource = [
      #     "${aws_s3_bucket.prd_bucket.arn}",
      #     "${aws_s3_bucket.prd_bucket.arn}/*"
      #   ]
      #   Condition = {
      #     StringEquals = {
      #       "aws:SourceAccount" = var.aws_account_id
      #     }
      #   }
      # }
    ]
  })
}

