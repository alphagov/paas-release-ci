#!/bin/sh

set -eu

export PASSWORD_STORE_DIR=${DESKPRO_PASSWORD_STORE_DIR}

DESKPRO_API_KEY=$(pass "deskpro/product_page/api_key")

SECRETS=$(mktemp secrets.yml.XXXXXX)
trap 'rm  "${SECRETS}"' EXIT

cat > "${SECRETS}" << EOF
---
deskpro_api_key: ${DESKPRO_API_KEY}
EOF

aws s3 cp "${SECRETS}" "s3://gds-paas-${DEPLOY_ENV}-state/deskpro-secrets.yml"
