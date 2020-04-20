#!/bin/sh

set -eu

export PASSWORD_STORE_DIR=${HACKMD_PASSWORD_STORE_DIR}

HACKMD_CLIENT_ID=$(pass "github.com/hackmd/github_client_id")
HACKMD_CLIENT_SECRET=$(pass "github.com/hackmd/github_client_secret")
HACKMD_SESSION_SECRET=$(date +%s | sha256sum | base64 | head -c 64 ; echo)

SECRETS=$(mktemp secrets.yml.XXXXXX)
trap 'rm  "${SECRETS}"' EXIT

cat > "${SECRETS}" << EOF
---
hackmd_client_id: ${HACKMD_CLIENT_ID}
hackmd_client_secret: ${HACKMD_CLIENT_SECRET}
hackmd_session_secret: ${HACKMD_SESSION_SECRET}
EOF

aws s3 cp "${SECRETS}" "s3://gds-paas-${DEPLOY_ENV}-state/hackmd-secrets.yml"
