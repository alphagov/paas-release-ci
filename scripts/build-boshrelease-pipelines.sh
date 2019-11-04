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
concourse_url: ${CONCOURSE_URL}
system_dns_zone_name: ${SYSTEM_DNS_ZONE_NAME}
aws_account: ${AWS_ACCOUNT}
releases_bucket_name: ${RELEASES_BUCKET_NAME:-gds-paas-${DEPLOY_ENV}-releases}
releases_blobs_bucket_name: ${RELEASES_BLOBS_BUCKET_NAME:-gds-paas-${DEPLOY_ENV}-releases-blobs}
github_access_token: ${GITHUB_ACCESS_TOKEN}
github_status_context: ${DEPLOY_ENV}/status
slack_webhook_url: ${SLACK_WEBHOOK_URL}
boshrelease_name: ${boshrelease_name}
github_repo: ${github_repo}
github_repo_uri: https://github.com/${github_repo}
final_release_branch: ${final_release_branch}
version_file: ${boshrelease_name}.version
EOF
}

setup_release_pipeline() {
  pipeline_name="${1}-release"
  boshrelease_name="$1"
  github_repo="$2"
  final_release_branch="$3"

  generate_vars_file > /dev/null # Check for missing vars

  bash "${SCRIPTS_DIR}/deploy-pipeline.sh" \
    "${pipeline_name}" \
    "${PIPELINES_DIR}/build-release.yml" \
    <(generate_vars_file)
}

remove_release_pipeline() {
  pipeline_name="${1}-release"
  ${FLY_CMD} -t "${FLY_TARGET}" destroy-pipeline --pipeline "${pipeline_name}" --non-interactive || true
}

echo Setting fork pipelines
setup_release_pipeline awslogs            alphagov/paas-awslogs-boshrelease            gds_master
setup_release_pipeline bosh               alphagov/paas-bosh                           gds_master
setup_release_pipeline bosh-aws-cpi       alphagov/paas-bosh-aws-cpi-release           gds_master
setup_release_pipeline capi               alphagov/paas-capi-release                   gds_master
setup_release_pipeline cflinuxfs3         alphagov/paas-cflinuxfs3-release             gds_master
setup_release_pipeline concourse          alphagov/paas-concourse-bosh-release         gds_master
setup_release_pipeline ipsec              alphagov/paas-ipsec-release                  gds_master
setup_release_pipeline oauth2-proxy       alphagov/paas-oauth2-proxy-boshrelease       gds_master
setup_release_pipeline prometheus         alphagov/paas-prometheus-boshrelease         gds_master
setup_release_pipeline routing            alphagov/paas-routing-release                gds_master
setup_release_pipeline uaa                alphagov/paas-uaa-release                    gds_master

echo Setting paas pipelines
setup_release_pipeline cdn-broker         alphagov/paas-cdn-broker-boshrelease         master
setup_release_pipeline elasticache-broker alphagov/paas-elasticache-broker-boshrelease master
setup_release_pipeline metric-exporter    alphagov/paas-metric-exporter-boshrelease    master
setup_release_pipeline observability      alphagov/paas-observability-release          master
setup_release_pipeline rds-broker         alphagov/paas-rds-broker-boshrelease         master
setup_release_pipeline s3-broker          alphagov/paas-s3-broker-boshrelease          master
setup_release_pipeline uaa-customized     alphagov/paas-uaa-customized-boshrelease     master
