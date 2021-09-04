# Emojirades Infrastructure

This repo holds the terraform that provisions all the emojirades infrastructure in AWS

## Install dependencies
```bash
# Linux
wget -O terraform.zip https://releases.hashicorp.com/terraform/1.0.6/terraform_1.0.6_linux_amd64.zip
unzip terraform.zip
sudo mv terraform /usr/bin/
rm terraform.zip

wget -O terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v0.31.8/terragrunt_linux_amd64
chmod +x terragrunt
sudo mv terragrunt /usr/bin/

# Mac
brew install terraform terragrunt
```

## Init the tier folder
```bash
# Init the 'bot' tier for prod
terragrunt init --terragrunt-config configuration/prod/prod/bot/terragrunt.hcl --terragrunt-working-dir tier/bot -upgrade

# Plan and apply the 'bot' tier for prod
terragrunt plan --terragrunt-config configuration/prod/prod/bot/terragrunt.hcl --terragrunt-working-dir tier/bot
terragrunt apply --terragrunt-config configuration/prod/prod/bot/terragrunt.hcl --terragrunt-working-dir tier/bot
```
