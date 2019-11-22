#!/bin/sh

set -eu

export PASSWORD_STORE_DIR=${DOCKERHUB_PASSWORD_STORE_DIR}

DOCKERHUB_ID=$(pass "dockerhub/ci/id")
DOCKERHUB_PASSWORD=$(pass "dockerhub/ci/password")

SECRETS=$(mktemp secrets.yml.XXXXXX)
trap 'rm  "${SECRETS}"' EXIT

cat > "${SECRETS}" << EOF
---
dockerhub_id: ${DOCKERHUB_ID}
dockerhub_password: ${DOCKERHUB_PASSWORD}
EOF

aws s3 cp "${SECRETS}" "s3://gds-paas-${DEPLOY_ENV}-state/dockerhub-secrets.yml"
