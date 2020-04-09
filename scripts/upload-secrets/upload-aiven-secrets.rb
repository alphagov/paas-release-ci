#!/usr/bin/env ruby
# frozen_string_literal: true

require "English"
require "yaml"
require "tempfile"

aiven_api_token = ENV["AIVEN_API_TOKEN"] || `pass aiven.io/ci/api_token`
aiven_project = ENV["AIVEN_PROJECT"] || "ci-testing"

credentials = {
  "credentials" => [
    {
      "name" => "/concourse/main/aiven-broker/aiven_api_token",
      "type" => "value",
      "value" => aiven_api_token.chomp
    },
    {
      "name" => "/concourse/main/aiven-broker/aiven_project",
      "type" => "value",
      "value" => aiven_project.chomp
    },
  ]
}

Tempfile.create("credhub-secrets") do |f|
  f.write(credentials.to_yaml)
  f.flush

  pid = spawn(
    "credhub import -f '#{f.path}'",
    in: STDIN, out: STDOUT, err: STDERR,
  )

  Process.wait pid
  raise 'Child process did not exit successfully' unless $CHILD_STATUS.success?
end
