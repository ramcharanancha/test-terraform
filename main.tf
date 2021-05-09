
resource "aws_s3_bucket" "ram-bucket-logs" {
    bucket = "ancharamcharan-test-s3-bucket-logs"
    acl = "log-delivery-write"

    versioning {
        enabled = true
    }

    
}

resource "aws_s3_bucket" "ram-bucket-1" {
    bucket = "ancharamcharan-test-s3-bucket"
    acl = "private"

    versioning {
        enabled = true
    } 
    logging {
      target_bucket = aws_s3_bucket.ram-bucket-logs.id
    }
    lifecycle_rule {
      abort_incomplete_multipart_upload_days = "7"
      enabled = true
      id = "ancha-datamgmt-lifecycle-role"
      noncurrent_version_expiration {
        days = 90   
      }
    }
    
    server_side_encryption_configuration {
      rule{
          apply_server_side_encryption_by_default {
            kms_master_key_id = "70748475-b1e2-4d63-b992-1ad737ce0f91"
            sse_algorithm = "aws:kms"
          }
      }
    }
    tags = {
      "contact" = "test"
    }
}

resource "aws_s3_bucket_policy" "ram-bucket-logs-policy" {
  bucket = aws_s3_bucket.ram-bucket-logs.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MYBUCKETPOLICY"
    Statement = [
      {
        Sid       = "allow-read-write-logs"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.ram-bucket-logs.arn,
          "${aws_s3_bucket.ram-bucket-logs.arn}/*",
        ]
      },
    ]
  })
}