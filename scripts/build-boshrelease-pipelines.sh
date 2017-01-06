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
releases_bucket_name: ${RELEASES_BUCKET_NAME:-gds-paas-${DEPLOY_ENV}-releases}
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

setup_release_pipeline() {
  boshrelease_name="$1"
  github_repo="$2"
  final_release_branch="$3"

  generate_vars_file > /dev/null # Check for missing vars

  bash "${SCRIPTS_DIR}/deploy-pipeline.sh" \
    "${boshrelease_name}" \
    "${PIPELINES_DIR}/build-release.yml" \
    <(generate_vars_file)
}

setup_release_pipeline rds-broker alphagov/paas-rds-broker-boshrelease master
setup_release_pipeline datadog-for-cloudfoundry alphagov/paas-datadog-for-cloudfoundry-boshrelease master
setup_release_pipeline logsearch-for-cloudfoundry alphagov/paas-logsearch-for-cloudfoundry gds_master
setup_release_pipeline paas-haproxy alphagov/paas-haproxy-release master
setup_release_pipeline graphite alphagov/paas-graphite-statsd-boshrelease gds_master
setup_release_pipeline collectd alphagov/paas-collectd-boshrelease gds_master
setup_release_pipeline datadog-agent alphagov/paas-datadog-agent-boshrelease gds_master
setup_release_pipeline syslog alphagov/paas-syslog-release gds_master
setup_release_pipeline ipsec alphagov/paas-ipsec-release gds_master
