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

CONCOURSE_ATC_USER=${CONCOURSE_ATC_USER:-admin}
if [ -z "${CONCOURSE_ATC_PASSWORD:-}" ]; then
  if [ -n "${CONCOURSE_ATC_PASSWORD_PASS_FILE:-}" ]; then
    CONCOURSE_ATC_PASSWORD=$(pass "${CONCOURSE_ATC_PASSWORD_PASS_FILE}")
  else
    CONCOURSE_ATC_PASSWORD=$(hashed_password "${AWS_SECRET_ACCESS_KEY}:${DEPLOY_ENV}:atc")
  fi
fi

if [ -z "${GITHUB_ACCESS_TOKEN:-}" ]; then
  GITHUB_ACCESS_TOKEN=$(pass github.com/release_ci_pr_status_token)
fi

cat <<EOF
export AWS_ACCOUNT=${AWS_ACCOUNT}
export DEPLOY_ENV=${DEPLOY_ENV}
export CONCOURSE_ATC_USER=${CONCOURSE_ATC_USER}
export CONCOURSE_ATC_PASSWORD=${CONCOURSE_ATC_PASSWORD}
export CONCOURSE_URL=${CONCOURSE_URL}
export GITHUB_ACCESS_TOKEN=${GITHUB_ACCESS_TOKEN}
export FLY_CMD=${FLY_CMD}
export FLY_TARGET=${FLY_TARGET}
EOF
