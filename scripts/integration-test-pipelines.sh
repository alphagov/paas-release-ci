#!/bin/bash
set -eu

SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)
PIPELINES_DIR="${SCRIPTS_DIR}/../pipelines"

# shellcheck disable=SC2091
$("${SCRIPTS_DIR}/environment.sh")
"${SCRIPTS_DIR}/fly_sync_and_login.sh"

generate_vars_file() {
  SSH_KEY=$(aws s3 cp s3://"${STATE_BUCKET_NAME:-gds-paas-${DEPLOY_ENV}-state}"/ci_build_tag_key -)
  cat <<EOF
---
pipeline_name: ${pipeline_name}
github_status_context: ${DEPLOY_ENV}/status
state_bucket: ${STATE_BUCKET_NAME:-gds-paas-${DEPLOY_ENV}-state}
aws_region: ${AWS_DEFAULT_REGION:-eu-west-1}
branch_name: ${BRANCH:-main}
organisation: ${organisation}
repository: ${repository}
github_repo: ${organisation}/${repository}
github_repo_uri: git@github.com:${organisation}/${repository}.git
tag_branch: ${tag_branch}
version_file: ${version_file}
EOF
  echo -e "tagging_key: |\n  ${SSH_KEY//$'\n'/$'\n'  }"
}

setup_test_pipeline() {
  pipeline_name="$1"
  version_file="version"
  organisation="$2"
  repository="$3"
  tag_branch="$4"

  generate_vars_file >/dev/null # Check for missing vars

  bash "${SCRIPTS_DIR}/deploy-pipeline.sh" \
    "${pipeline_name}" \
    "${PIPELINES_DIR}/integration-test.yml" \
    <(generate_vars_file)

}

remove_test_pipeline() {
  pipeline_name="${1}"
  ${FLY_CMD} -t "${FLY_TARGET}" destroy-pipeline --pipeline "${pipeline_name}" --non-interactive || true
}

setup_test_pipeline paas-billing alphagov paas-billing main
setup_test_pipeline elasticache-broker alphagov paas-elasticache-broker main
setup_test_pipeline paas-accounts alphagov paas-accounts main
setup_test_pipeline paas-auditor alphagov paas-auditor main
setup_test_pipeline rds-metric-collector alphagov paas-rds-metric-collector main
setup_test_pipeline paas-admin alphagov paas-admin main
setup_test_pipeline paas-log-cache-adapter alphagov paas-log-cache-adapter main
setup_test_pipeline aiven-broker alphagov paas-aiven-broker main
setup_test_pipeline s3-broker alphagov paas-s3-broker main
setup_test_pipeline sqs-broker alphagov paas-sqs-broker main
setup_test_pipeline paas-service-broker-base alphagov paas-service-broker-base main
setup_test_pipeline paas-prometheus-endpoints alphagov paas-prometheus-endpoints main
