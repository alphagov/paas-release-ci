#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "./upload-secrets.rb"

slack_webhook_url = ENV["SLACK_WEBHOOK_URL"] || `pass gds.slack.com/concourse_slack_webhook_url`

secrets = [
  {
    "name" => "/concourse/main/slack_webhook_url",
    "type" => "value",
    "value" => slack_webhook_url.chomp
  },
]

upload_secrets(secrets)
