#!/bin/bash
set -eu

SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)
PIPELINES_DIR="${SCRIPTS_DIR}/../pipelines"

# shellcheck disable=SC2091
$("${SCRIPTS_DIR}/environment.sh")
"${SCRIPTS_DIR}/fly_sync_and_login.sh"

generate_vars_file() {
   cat <<EOF
---
aws_account: ${AWS_ACCOUNT:-dev}
deploy_env: ${DEPLOY_ENV}
branch_name: ${BRANCH:-master}
aws_region: ${AWS_DEFAULT_REGION:-eu-west-1}
concourse_atc_password: ${CONCOURSE_ATC_PASSWORD}
concourse_url: ${CONCOURSE_URL}
system_dns_zone_name: ${SYSTEM_DNS_ZONE_NAME}
aws_account: ${AWS_ACCOUNT}
bucket_name: gds-paas-${DEPLOY_ENV}-releases
github_access_token: ${GITHUB_ACCESS_TOKEN}
github_status_context: ${DEPLOY_ENV}/status
# move
boshrelease_name: ${boshrelease_name}
github_repo: ${github_repo}
github_repo_uri: https://github.com/${github_repo}
final_release_branch: ${final_release_branch}
version_file: ${boshrelease_name}.version
EOF
}

boshrelease_name=rds-broker
github_repo=alphagov/paas-rds-broker-boshrelease
final_release_branch=master

generate_vars_file > /dev/null # Check for missing vars

bash "${SCRIPTS_DIR}/deploy-pipeline.sh" \
  "${boshrelease_name}" \
  "${PIPELINES_DIR}/build-release.yml" \
  <(generate_vars_file)
