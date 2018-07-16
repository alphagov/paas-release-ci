#!/bin/sh

set -eu

export PASSWORD_STORE_DIR=${AIVEN_PASSWORD_STORE_DIR}

AIVEN_API_TOKEN=$(pass "aiven.io/ci/api_token")

SECRETS=$(mktemp secrets.yml.XXXXXX)
trap 'rm  "${SECRETS}"' EXIT

cat > "${SECRETS}" << EOF
---
aiven_api_token: ${AIVEN_API_TOKEN}
aiven_project: ci-testing
EOF

aws s3 cp "${SECRETS}" "s3://gds-paas-${DEPLOY_ENV}-state/aiven-broker-secrets.yml"
