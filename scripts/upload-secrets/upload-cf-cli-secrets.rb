#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "./upload-secrets"

`export PASSWORD_STORE_DIR=${CF_CLI_PASSWORD_STORE_DIR}`

aws_account = ENV["AWS_ACCOUNT"] || raise("AWS_ACCOUNT env var must be set")
deploy_env = ENV["DEPLOY_ENV"] || raise("DEPLOY_ENV env var must be set")
cf_user = ENV["CF_USER"] || `pass #{aws_account}_deployments/#{deploy_env}/cf_app_deployer_user`
cf_password = ENV["CF_PASSWORD"] || `pass #{aws_account}_deployments/#{deploy_env}/cf_app_deployer_password`

secrets = [
  {
    "name" => "/concourse/main/cf_user",
    "type" => "value",
    "value" => cf_user.chomp,
  },
  {
    "name" => "/concourse/main/cf_password",
    "type" => "value",
    "value" => cf_password.chomp,
  },
]

upload_secrets(secrets)
