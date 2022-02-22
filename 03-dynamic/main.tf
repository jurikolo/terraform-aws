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
      version = "~> 4.2.0"
    }
  }
}

provider "aws" {
  region     = "eu-central-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_key_id
}

locals {
  dynamodb_attributes = [
    {
      name = "id"
      type = "S"
    }, {
      name = "date"
      type = "N"
    }
  ]
}

resource "aws_dynamodb_table" "dynamodb" {
  name           = "Terraform"
  billing_mode   = "PROVISIONED"
  write_capacity = 1
  read_capacity  = 1
  hash_key       = "id"
  range_key      = "date"

  ttl {
    enabled        = true
    attribute_name = "ttl"
  }

  tags = {
    Name       = "Terraform"
    CostCenter = "Terraform"
  }

  dynamic "attribute" {
    for_each = local.dynamodb_attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }
}

output "dynamodb_arn" {
  value = aws_dynamodb_table.dynamodb.arn
}