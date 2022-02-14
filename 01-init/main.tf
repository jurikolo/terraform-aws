terraform {
  cloud {
    organization = "jurikolo"

    workspaces {
      name = "aws-test-1"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
  }
}

provider "aws" {
  region     = "eu-central-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_key_id
}

data "aws_s3_bucket" "jurikolo_name" {
  bucket = "jurikolo.name"
}

output "s3_arn" {
  value = data.aws_s3_bucket.jurikolo_name.arn
}