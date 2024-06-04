variable "github_identifiers" {
  description = "Github users or organisations."
  type        = list(string)
}

variable "repository_name" {
  description = "The name of the repo that is trusted."
  type        = string
}

variable "deployment_role_name" {
  description = "The name of the rdeployment iam role."
  type        = string
}