#!/bin/sh

set -eu

export PASSWORD_STORE_DIR=${HACKMD_PASSWORD_STORE_DIR}

HACKMD_CLIENT_ID=$(pass "github.com/hackmd/github_client_id")
HACKMD_CLIENT_SECRET=$(pass "github.com/hackmd/github_client_secret")

SECRETS=$(mktemp secrets.yml.XXXXXX)
trap 'rm  "${SECRETS}"' EXIT

cat > "${SECRETS}" << EOF
---
hackmd_client_id: ${HACKMD_CLIENT_ID}
hackmd_client_secret: ${HACKMD_CLIENT_SECRET}
EOF

aws s3 cp "${SECRETS}" "s3://gds-paas-${DEPLOY_ENV}-state/hackmd-secrets.yml"
