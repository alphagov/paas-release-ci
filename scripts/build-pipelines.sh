#!/bin/bash
set -eu

SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)
PIPELINES_DIR="${SCRIPTS_DIR}/../pipelines"

# shellcheck disable=SC2091
$("${SCRIPTS_DIR}/environment.sh" "$@")
"${SCRIPTS_DIR}/fly_sync_and_login.sh"

env=${DEPLOY_ENV}

generate_vars_file() {
   cat <<EOF
---
aws_account: ${AWS_ACCOUNT:-dev}
deploy_env: ${env}
branch_name: ${BRANCH:-master}
aws_region: ${AWS_DEFAULT_REGION:-eu-west-1}
concourse_atc_password: ${CONCOURSE_ATC_PASSWORD}
system_dns_zone_name: ${SYSTEM_DNS_ZONE_NAME}
aws_account: ${AWS_ACCOUNT}
bucket_name: gds-paas-${AWS_ACCOUNT}-boshreleases
# move
repo_uri: https://github.com/alphagov/paas-rds-broker-boshrelease.git
access_token: $(pass github.com/release_ci_pr_status_token)
repo: alphagov/paas-rds-broker-boshrelease
EOF
}

generate_vars_file > /dev/null # Check for missing vars

for BOSH_RELEASE in rds-broker; do
  bash "${SCRIPTS_DIR}/deploy-pipeline.sh" \
    "${env}" "${BOSH_RELEASE}" \
    "${PIPELINES_DIR}/build-release.yml" \
    <(generate_vars_file)
done
