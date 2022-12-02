#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "./upload-secrets"

`export PASSWORD_STORE_DIR=${ZENDESK_PASSWORD_STORE_DIR}`

zendesk_user = ENV["ZENDESK_USER"] || `pass zendesk/api_user`
zendesk_token = ENV["ZENEDSK_PASSWORD"] || `pass zendesk/api_key`

secrets = [
  {
    "name" => "/concourse/main/zendesk_user",
    "type" => "value",
    "value" => zendesk_user.chomp,
  },
  {
    "name" => "/concourse/main/zendesk_token",
    "type" => "value",
    "value" => zendesk_token.chomp,
  },
]

upload_secrets(secrets)
