output "this_aws_kms_key_arn" {
  description = "The arn of the sops kms key"
  value = aws_kms_key.this.arn
}

output "ir_aws_kms_key_arn" {
  description = "The arn of the ir sops kms key"
  value = aws_kms_key.ir.arn
}