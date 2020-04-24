#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "./upload-secrets.rb"

github_access_token = ENV["GITHUB_ACCESS_TOKEN"] || `pass github.com/release_ci_pr_status_token`

secrets = [
  {
    "name" => "/concourse/main/github_access_token",
    "type" => "value",
    "value" => github_access_token.chomp
  },
]

upload_secrets(secrets)
