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
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.0"
    }
  }
}

provider "aws" {
  region     = "eu-central-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_key_id
}

locals {
  function_name       = "dynamo-data-generator"
  dynamodb_attributes = [
    {
      name = "id"
      type = "S"
    }, {
      name = "date"
      type = "N"
    }
  ]

  tags = {
    Name       = "Terraform"
    CostCenter = "Terraform"
  }
}

resource "aws_dynamodb_table" "dynamodb" {
  name           = "Terraform"
  billing_mode   = "PROVISIONED"
  write_capacity = 1
  read_capacity  = 1
  hash_key       = "id"
  range_key      = "date"
  tags           = local.tags

  ttl {
    enabled        = true
    attribute_name = "ttl"
  }

  dynamic "attribute" {
    for_each = local.dynamodb_attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }
}

resource "aws_iam_role" "lambda" {
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  inline_policy {
    name   = "dynamodb"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action = [
            "dynamodb:PutItem",
            "dynamodb:UpdateItem"
          ]
          Effect   = "Allow"
          Resource = aws_dynamodb_table.dynamodb.arn
        }
      ]
    })
  }
  tags = local.tags
}

resource "aws_s3_bucket" "s3" {
  bucket        = var.aws_s3_bucket_name
  force_destroy = true
  tags          = local.tags
}

resource "aws_s3_object" "lambda" {
  bucket     = aws_s3_bucket.s3.id
  key        = "lambdas/${local.function_name}.zip"
  source     = "${path.module}/lambdas/${local.function_name}.zip"
  etag       = filemd5("${path.module}/lambdas/${local.function_name}.zip")

}

resource "aws_lambda_function" "lambda" {
  function_name    = local.function_name
  s3_bucket        = aws_s3_bucket.s3.bucket
  s3_key           = aws_s3_object.lambda.key
  role             = aws_iam_role.lambda.arn
  runtime          = "python3.9"
  handler          = "lambda.handler"
  source_code_hash = filebase64sha256("lambdas/${local.function_name}.zip")
  tags             = local.tags
  depends_on       = [ aws_s3_bucket.s3 ]
}

output "dynamodb_arn" {
  value = aws_dynamodb_table.dynamodb.arn
}