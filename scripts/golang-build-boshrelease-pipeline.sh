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
branch_name: ${BRANCH:-main}
aws_region: ${AWS_DEFAULT_REGION:-eu-west-1}
concourse_url: ${CONCOURSE_URL}
system_dns_zone_name: ${SYSTEM_DNS_ZONE_NAME}
aws_account: ${AWS_ACCOUNT}
releases_bucket_name: ${RELEASES_BUCKET_NAME:-gds-paas-${DEPLOY_ENV}-releases}
releases_blobs_bucket_name: ${RELEASES_BLOBS_BUCKET_NAME:-gds-paas-${DEPLOY_ENV}-releases-blobs}
github_status_context: ${DEPLOY_ENV}/status
boshrelease_name: ${boshrelease_name}
github_repo: ${github_repo}
github_repo_uri: https://github.com/${github_repo}
final_release_branch: ${final_release_branch}
version_file: ${boshrelease_name}.version
golang_version: ${GOLANG_VERSION:-1.20}
EOF
}

setup_release_pipeline() {
  pipeline_name="${1}-release"
  boshrelease_name="$1"
  github_repo="$2"
  final_release_branch="$3"

  echo "Setting up pipeline ${pipeline_name} for ${boshrelease_name} from ${github_repo} on branch ${final_release_branch}"

  generate_vars_file >/dev/null # Check for missing vars

  bash "${SCRIPTS_DIR}/deploy-pipeline.sh" \
    "${pipeline_name}" \
    "${PIPELINES_DIR}/golang-release.yml" \
    <(generate_vars_file)
}

remove_release_pipeline() {
  pipeline_name="${1}-release"
  ${FLY_CMD} -t "${FLY_TARGET}" destroy-pipeline --pipeline "${pipeline_name}" --non-interactive || true
}

setup_release_pipeline golang-s3-broker alphagov/paas-s3-broker-boshrelease main
