# terraform-aws
Experiments with AWS using Terraform

## Terraform Cloud
This project uses [Terraform Cloud](https://www.terraform.io/cloud-docs).
Due to this fact files like `terraform.tfvars` doesn't work by default, you shall configure variables in the cloud.

## AWS resources
Resources provisioned are part of always free "Free Tier". More details: [link](https://aws.amazon.com/free/?all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=tier%23always-free&awsf.Free%20Tier%20Categories=*all) 

## Symlinks
In order to upload ZIP archive to OSS bucket and make sure it uploads the file on change, it's necessary to avoid `archive_file` Terraform data source, as it brings chicken and egg problem.
Instead, develop the function in a separate directory, create the ZIP archive, create symlink to an archive to a Terraform module and execute Terraform.
For symlink use following syntax from Terraform module:

```sh
ln -s ../extras/lambdas lambdas
```

## Lambda development
To create ZIP archive, do following from `extras/lambdas` directory:
```sh
zip -j dynamo-data-generator.zip dynamo-data-generator/*
```