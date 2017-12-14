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
app_name: ${APP_NAME}
app_github_repo_uri: ${APP_REPOSITORY}
app_repository_branch: ${APP_BRANCH}
app_deployment_docker_image: ${APP_DOCKER_IMAGE}
app_deployment_docker_image_tag: ${APP_DOCKER_IMAGE_TAG:-latest}
cf_api: ${CF_API}
cf_api_secure: ${CF_API_SECURE:-}
cf_user: ${CF_USER}
cf_password: ${CF_PASSWORD}
cf_org: ${CF_ORG:-${APP_CF_ORG}}
cf_space: ${CF_SPACE:-${APP_CF_SPACE}}
state_bucket: ${STATE_BUCKET_NAME:-gds-paas-${DEPLOY_ENV}-state}
aws_region: ${AWS_DEFAULT_REGION:-eu-west-1}
secrets_file: ${SECRETS_FILE:-no-secrets-needed}
EOF
}

for app in ${SCRIPTS_DIR}/../app-deploy.d/* ; do
  (
    # shellcheck source=/dev/null
    . "${app}"

    generate_vars_file > /dev/null # Check for missing vars

    bash "${SCRIPTS_DIR}/deploy-pipeline.sh" \
    "${APP_NAME}" \
    "${PIPELINES_DIR}/deploy-app.yml" \
    <(generate_vars_file)
  )
done
