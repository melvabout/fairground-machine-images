data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "github_assume" {
  statement {

    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_identifiers.0}/${var.repository_name}:*"]

    }
  }
}

data "aws_iam_policy_document" "github_deployment" {

  statement {

    actions = [
      "ec2:*",
      "iam:*",
      "kms:*",
    ]

    effect = "Allow"

    resources = ["*"]
  }

  statement {

    not_actions = [
      "cloudfront:*",
      "iam:*",
      "route53:*",
      "route53domains:*",
      "support:*"
    ]

    effect = "Deny"

    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = ["eu-west-2"]
    }
  }
}