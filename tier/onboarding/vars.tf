# Variables
variable "common_dir" {
  type = string
}

variable "account_dir" {
  type = string
}

variable "env_dir" {
  type = string
}

variable "tier_dir" {
  type = string
}

variable "overall_tags" {
  type = map(string)
}

variable "overall_config" {
  type = map(string)
}

variable "account_tags" {
  type = map(string)
}

variable "account_config" {
  type = map(string)
}

variable "environment_tags" {
  type = map(string)
}

variable "environment_config" {
  type = any
}

variable "tier_tags" {
  type = map(string)
}

variable "tier_config" {
  type = any
}

# Convenience derives
locals {
  resource_prefix = lookup(var.overall_config, "resource_prefix")

  account      = lookup(var.account_tags, "account")
  account_tags = merge(var.overall_tags, var.account_tags)

  environment      = lookup(var.environment_tags, "environment")
  environment_tags = merge(var.overall_tags, var.account_tags, var.environment_tags)

  environment_zone = local.environment == "prod" ? "${lookup(var.overall_config, "parent_zone_name")}" : "${local.environment}.${local.account}.${lookup(var.overall_config, "parent_zone_name")}"
  environment_zone_host = substr(local.environment_zone, 0, length(local.environment_zone) - 1)

  tier = lookup(var.tier_tags, "tier")
  tier_tags = merge(var.overall_tags, var.account_tags, var.environment_tags, var.tier_tags)

  prefix = "${local.resource_prefix}-${local.environment}"

  onboarding_bucket = local.environment == "prod" ? "emojirades" : "emojirades-${local.environment}"
}
