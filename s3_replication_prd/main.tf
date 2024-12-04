resource "aws_s3_bucket" "prd_bucket" {
  bucket        = var.prd_bucket_name
}

resource "aws_s3_bucket_versioning" "prd_bucket_versioning" {
  bucket = aws_s3_bucket.prd_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "prd_bucket_policy" {
  depends_on = [ aws_s3_bucket_versioning.prd_bucket_versioning ]
  bucket = aws_s3_bucket.prd_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
          {
      "Sid": "GrantFullAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::618844571952:role/${var.qa_replication_role_name}"
      },
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.prd_bucket.arn}",
        "${aws_s3_bucket.prd_bucket.arn}/*"
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

