#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "./upload-secrets.rb"

github_access_token = ENV["GITHUB_ACCESS_TOKEN"] || `pass github.com/release_ci_pr_status_token`
github_username = ENV["GITHUB_USERNAME"] || `pass github.com/ci-user-username`
github_registry_access_token = ENV["GITHUB_REGISTRY_ACCESS_TOKEN"] || `pass github.com/ci-user-container-registry-token`

secrets = [
  {
    "name" => "/concourse/main/github_access_token",
    "type" => "value",
    "value" => github_access_token.chomp
  },
  {
    "name" => "/concourse/main/github_username",
    "type" => "value",
    "value" => github_username.chomp
  },
  {
    "name" => "/concourse/main/github_registry_access_token",
    "type" => "value",
    "value" => github_registry_access_token.chomp
  },
]

upload_secrets(secrets)
