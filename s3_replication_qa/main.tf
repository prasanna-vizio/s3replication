resource "aws_s3_bucket" "qa_bucket" {
  bucket        = var.qa_bucket_name
 }

 resource "aws_s3_bucket_versioning" "qa_bucket_versioning" {
  bucket = aws_s3_bucket.qa_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "qa_bucket_replication_role" {
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
  name   = "${var.qa_bucket_name}-replication-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # {
      #   Sid    = "AllowFullS3Access"
      #   Effect = "Allow"
      #   Action = "s3:*" # All S3 actions
      #   # Resource = "*"  # All S3 resources
      #   Resource = "${aws_s3_bucket.qa_bucket.arn}"
      # }
              {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "qa_bucket_replication_policy_attachment" {
  role       = aws_iam_role.qa_bucket_replication_role.name
  # policy_arn = aws_iam_policy.qa_bucket_replication_policy.arn
  policy_arn = arn:aws:iam::618844571952:role/ServiceRoleS3BatchOperations
}

resource "aws_s3_bucket_replication_configuration" "qa_bucket_replication_configuration" {
  bucket = aws_s3_bucket.qa_bucket.id
  role = aws_iam_role.qa_bucket_replication_role.arn
    rule {
    id = "ReplicationRule"

    filter {
      prefix = "" # Replicate all objects
    }

    status = "Enabled"

    destination {
      bucket        = "arn:aws:s3:::${var.prd_bucket_name}"
      # storage_class = "STANDARD"
    }
    delete_marker_replication {
    status = "Enabled"
    }
  }

}