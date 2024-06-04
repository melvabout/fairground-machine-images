include "root" {
  path = find_in_parent_folders()
}

terraform {
  source =  "${path_relative_from_include()}/../../terraform/${path_relative_to_include()}"
}

inputs = {
  deployment_role_name = "github-fairground-machine-images-deployment-role"
  github_identifiers = ["melvabout"]
  repository_name = "fairground-machine-images"
}