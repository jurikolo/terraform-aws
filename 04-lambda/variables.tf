variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_key_id" {
  type = string
}

variable "aws_s3_bucket_name" {
  type    = string
  default = "jurikolo-terraform-s3-bucket-42"
}