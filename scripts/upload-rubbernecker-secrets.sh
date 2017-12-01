#!/bin/sh

set -eu

export PASSWORD_STORE_DIR=${RUBBERNECKER_PASSWORD_STORE_DIR}

PIVOTAL_API_KEY=$(pass "pivotal/tracker_token")
PAGERDUTY_API_TOKEN=$(pass "pagerduty/rubbernecker_api_token")

SECRETS=$(mktemp secrets.yml.XXXXXX)
trap 'rm "${SECRETS}"' EXIT

cat > "${SECRETS}" << EOF
---
pivotal_project_id: 1275640
pivotal_api_key: ${PIVOTAL_API_KEY}
pagerduty_api_token: ${PAGERDUTY_API_TOKEN}
EOF

aws s3 cp "${SECRETS}" "s3://gds-paas-${DEPLOY_ENV}-state/rubbernecker-secrets.yml"
