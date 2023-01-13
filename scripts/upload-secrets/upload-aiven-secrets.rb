#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "./upload-secrets"

aiven_api_token = ENV["AIVEN_API_TOKEN"] || `pass aiven.io/ci/api_token`
aiven_project = ENV["AIVEN_PROJECT"] || "ci-testing"

secrets = [
  {
    "name" => "/concourse/main/aiven-broker/aiven_api_token",
    "type" => "value",
    "value" => aiven_api_token.chomp,
  },
  {
    "name" => "/concourse/main/aiven-broker/aiven_project",
    "type" => "value",
    "value" => aiven_project.chomp,
  },
]

upload_secrets(secrets)
