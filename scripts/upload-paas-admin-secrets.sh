#!/bin/sh

set -eu

export PASSWORD_STORE_DIR=${PAAS_ADMIN_PASSWORD_STORE_DIR}

NOTIFY_WELCOME_TEMPLATE_ID=""
NOTIFY_API_KEY=$(paas "notify/${DEPLOY_ENV}/api_key")

SECRETS=$(mktemp secrets.yml.XXXXXX)
trap 'rm "${SECRETS}"' EXIT

cat > "${SECRETS}" << EOF
---
notify_welcome_template_id: ${NOTIFY_WELCOME_TEMPLATE_ID}
notify_api_key: ${NOTIFY_API_KEY}
EOF

aws s3 cp "${SECRETS}" "s3://gds-paas-${DEPLOY_ENV}-state/paas-admin-secrets.yml"
