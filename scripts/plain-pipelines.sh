#!/bin/bash
set -eu

SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)

# shellcheck disable=SC2091
$("${SCRIPTS_DIR}/environment.sh")
"${SCRIPTS_DIR}/fly_sync_and_login.sh"

generate_vars_file() {
   cat <<EOF
---
aws_account: ${AWS_ACCOUNT}
deploy_env: ${DEPLOY_ENV}
cf_user: ${CF_USER}
cf_password: ${CF_PASSWORD}
state_bucket: ${STATE_BUCKET_NAME:-gds-paas-${DEPLOY_ENV}-state}
aws_region: ${AWS_DEFAULT_REGION:-eu-west-1}
cf_apps_domain: ${CF_APPS_DOMAIN}
cf_system_domain: ${CF_SYSTEM_DOMAIN}
slack_webhook_url: ${SLACK_WEBHOOK_URL}
EOF
}

for pipeline_path in ${SCRIPTS_DIR}/../pipelines/plain_pipelines/* ; do
  (
    pipeline_name=${pipeline_path##*/}
    pipeline_name=${pipeline_name%%.yml}

    generate_vars_file > /dev/null # Check for missing vars
    bash "${SCRIPTS_DIR}/deploy-pipeline.sh" \
    "${pipeline_name}" \
    "${pipeline_path}" \
    <(generate_vars_file)
  )
done
