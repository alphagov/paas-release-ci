#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "./upload-secrets"

`export PASSWORD_STORE_DIR=${RUBBERNECKER_PASSWORD_STORE_DIR}`

pivotal_tracker_project_id = ENV["PIVOTAL_TRACKER_PROJECT_ID"] || "1275640"
pivotal_tracker_api_token = ENV["PIVOTAL_TRACKER_API_TOKEN"] || `pass pivotal/rubbernecker_api_token`
pagerduty_authtoken = ENV["PAGERDUTY_AUTH_TOKEN"] || `pass pagerduty/rubbernecker_api_token`

secrets = [
  {
    "name" => "/concourse/main/pivotal_tracker_project_id",
    "type" => "value",
    "value" => pivotal_tracker_project_id.chomp,
  },
  {
    "name" => "/concourse/main/pivotal_tracker_api_token",
    "type" => "value",
    "value" => pivotal_tracker_api_token.chomp,
  },
  {
    "name" => "/concourse/main/pagerduty_authtoken",
    "type" => "value",
    "value" => pagerduty_authtoken.chomp,
  },
]

upload_secrets(secrets)
