include {
  path = find_in_parent_folders()
}

terraform {
  extra_arguments "custom_vars" {
    commands = get_terraform_commands_that_need_vars()

    arguments = [
      "-var-file=${get_terragrunt_dir()}/../../../terraform.tfvars",
      "-var-file=${get_terragrunt_dir()}/../../terraform.tfvars",
      "-var-file=${get_terragrunt_dir()}/../terraform.tfvars",
      "-var-file=${get_terragrunt_dir()}/terraform.tfvars",
      "-var",
      "common_dir=${get_terragrunt_dir()}/../../../common/dns",
      "-var",
      "account_dir=${get_terragrunt_dir()}/../../",
      "-var",
      "env_dir=${get_terragrunt_dir()}/../",
      "-var",
      "tier_dir=${get_terragrunt_dir()}",
    ]
  }
}
