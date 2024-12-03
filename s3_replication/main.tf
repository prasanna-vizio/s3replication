resource "aws_s3_bucket" "source_bucket" {
  bucket        = var.source_bucket_name
 }

resource "aws_s3_bucket" "destination_bucket" {
  bucket        = var.destination_bucket_name
}

resource "aws_s3_bucket_versioning" "source_versioning" {
  bucket = aws_s3_bucket.source_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "destination_versioning" {
  bucket = aws_s3_bucket.destination_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "destination_bucket_policy" {
  bucket = aws_s3_bucket.destination_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "ReplicationPolicy"
        Effect    = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action    = "*"
         Resource = [
          "${aws_s3_bucket.destination_bucket.arn}",
          "${aws_s3_bucket.destination_bucket.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.aws_account_id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "replication_role" {
  name               = var.replication_role_name
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

resource "aws_iam_policy" "replication_policy" {
  name   = "${var.replication_role_name}-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowFullS3Access"
        Effect = "Allow"
        Action = "s3:*" # All S3 actions
        Resource = "*"  # All S3 resources
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication_policy_attachment" {
  role       = aws_iam_role.replication_role.name
  policy_arn = aws_iam_policy.replication_policy.arn
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  bucket = aws_s3_bucket.source_bucket.id
  depends_on = [ aws_s3_bucket_versioning.source_versioning ]
  role = aws_iam_role.replication_role.arn
    rule {
    id = "ReplicationRule"

    filter {
      prefix = "" # Replicate all objects
    }

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.destination_bucket.arn
      # storage_class = "STANDARD"
    }
    delete_marker_replication {
    status = "Enabled"
    }
  }

}

