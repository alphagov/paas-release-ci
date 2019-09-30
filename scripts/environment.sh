#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
FLY_DIR=$(cd "${SCRIPT_DIR}/../bin" && pwd)

hashed_password() {
  echo "$1" | shasum -a 256 | base64 | head -c 32
}

if [ -z "${DEPLOY_ENV:-}" ]; then
  echo "Must specify DEPLOY_ENV as environment variable" 1>&2
  exit 1
fi

AWS_ACCOUNT=${AWS_ACCOUNT:-dev}

CONCOURSE_URL="${CONCOURSE_URL:-https://concourse.${SYSTEM_DNS_ZONE_NAME}}"
FLY_TARGET=${FLY_TARGET:-$DEPLOY_ENV}
FLY_CMD="${FLY_DIR}/fly"

if [ -z "${GITHUB_ACCESS_TOKEN:-}" ]; then
  GITHUB_ACCESS_TOKEN=$(pass github.com/release_ci_pr_status_token)
fi

if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
  SLACK_WEBHOOK_URL=$(pass gds.slack.com/concourse_slack_webhook_url)
fi

if [ -z "${CF_USER:-}" ]; then
  if aws s3 ls "s3://gds-paas-${DEPLOY_ENV}-state/cf-cli-secrets.yml" > /dev/null; then
    CF_USER=$(scripts/val_from_yaml.rb secrets.cf_user <(aws s3 cp "s3://gds-paas-${DEPLOY_ENV}-state/cf-cli-secrets.yml" -))
  else
    CF_USER="admin"
  fi
fi
if [ -z "${CF_PASSWORD:-}" ]; then
  if aws s3 ls "s3://gds-paas-${DEPLOY_ENV}-state/cf-cli-secrets.yml" > /dev/null; then
    CF_PASSWORD=$(scripts/val_from_yaml.rb secrets.cf_password <(aws s3 cp "s3://gds-paas-${DEPLOY_ENV}-state/cf-cli-secrets.yml" -))
  else
    CF_PASSWORD=""
  fi
fi

cat <<EOF
export AWS_ACCOUNT=${AWS_ACCOUNT}
export DEPLOY_ENV=${DEPLOY_ENV}
export CONCOURSE_URL=${CONCOURSE_URL}
export GITHUB_ACCESS_TOKEN=${GITHUB_ACCESS_TOKEN}
export SLACK_WEBHOOK_URL=${SLACK_WEBHOOK_URL}
export FLY_CMD=${FLY_CMD}
export FLY_TARGET=${FLY_TARGET}
export CF_USER=${CF_USER}
export CF_PASSWORD=${CF_PASSWORD}
EOF
