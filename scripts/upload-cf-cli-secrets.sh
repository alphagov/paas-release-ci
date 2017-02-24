#!/bin/sh

set -eu

export PASSWORD_STORE_DIR=${CF_CLI_PASSWORD_STORE_DIR}

if [ -n "${CF_USER:-}" ]; then
  cf_user="${CF_USER}"
else
  cf_user=$(pass "${AWS_ACCOUNT}_deployments/${DEPLOY_ENV}/cf_app_deployer_user")
fi
if [ -n "${CF_PASSWORD:-}" ]; then
  cf_password="${CF_PASSWORD}"
else
  cf_password=$(pass "${AWS_ACCOUNT}_deployments/${DEPLOY_ENV}/cf_app_deployer_password")
fi

SECRETS=$(mktemp secrets.yml.XXXXXX)
trap 'rm  "${SECRETS}"' EXIT

cat > "${SECRETS}" << EOF
---
secrets:
  cf_user: ${cf_user}
  cf_password: ${cf_password}
EOF

aws s3 cp "${SECRETS}" "s3://gds-paas-${DEPLOY_ENV}-state/cf-cli-secrets.yml"
