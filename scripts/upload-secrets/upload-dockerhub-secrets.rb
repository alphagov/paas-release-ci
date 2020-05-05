#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "./upload-secrets.rb"

dockerhub_username = ENV["DOCKERHUB_USERNAME"] || `pass dockerhub/ci/id`
dockerhub_password = ENV["DOCKERHUB_PASSWORD"] || `pass dockerhub/ci/password`

secrets = [
  {
    "name" => "/concourse/main/dockerhub_username",
    "type" => "value",
    "value" => dockerhub_username.chomp
  },
  {
    "name" => "/concourse/main/dockerhub_password",
    "type" => "value",
    "value" => dockerhub_password.chomp
  },
]

upload_secrets(secrets)
