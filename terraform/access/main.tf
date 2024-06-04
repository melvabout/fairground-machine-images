terraform {
  backend "s3" {}
}

resource "aws_iam_role" "github" {
  name               = var.deployment_role_name
  assume_role_policy = data.aws_iam_policy_document.github_assume.json
}

resource "aws_iam_policy" "github" {
  name   = "github-machine-images-deployment-policy"
  policy = data.aws_iam_policy_document.github_deployment.json
}

resource "aws_iam_role_policy_attachment" "github" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.github.arn
}
