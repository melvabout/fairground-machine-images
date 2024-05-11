terraform {
  backend "s3" {}
}

provider "aws" {
  alias  = "ir"
  region = "eu-west-1"
}

resource "aws_kms_key" "this" {
  description             = "KMS key for sops encryption"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "this" {
  name          = "alias/fairground-machine-images-sops-alias"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_kms_key" "ir" {
  provider                = aws.ir
  description             = "KMS key for sops encryption"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "ir" {
  provider      = aws.ir
  name          = "alias/fairground-machine-images-sops-ir-alias"
  target_key_id = aws_kms_key.ir.key_id
}
