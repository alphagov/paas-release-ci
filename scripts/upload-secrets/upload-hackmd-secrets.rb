#!/usr/bin/env ruby
# frozen_string_literal: true

require 'securerandom'
require_relative "./upload-secrets.rb"

`export PASSWORD_STORE_DIR=${HACKMD_PASSWORD_STORE_DIR}`

hackmd_github_client_id = ENV["HACKMD_GITHUB_CLIENT_ID"] || `pass github.com/hackmd/github_client_id`
hackmd_github_client_secret = ENV["HACKMD_GITHUB_CLIENT_SECRET"] || `pass github.com/hackmd/github_client_secret`
hackmd_session_secret = ENV["HACKMD_SESSION_SECRET"] || SecureRandom.hex(64)

secrets = [
  {
    "name" => "/concourse/main/hackmd_github_client_id",
    "type" => "value",
    "value" => hackmd_github_client_id.chomp,
  },
  {
    "name" => "/concourse/main/hackmd_github_client_secret",
    "type" => "value",
    "value" => hackmd_github_client_secret.chomp,
  },
  {
    "name" => "/concourse/main/hackmd_session_secret",
    "type" => "value",
    "value" => hackmd_session_secret.chomp,
  },
]

upload_secrets(secrets)
