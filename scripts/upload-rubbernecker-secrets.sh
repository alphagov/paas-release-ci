#!/bin/sh

set -eu

export PASSWORD_STORE_DIR=${RUBBERNECKER_PASSWORD_STORE_DIR}

PIVOTAL_TRACKER_API_TOKEN=$(pass "pivotal/rubbernecker_api_token")
PAGERDUTY_AUTHTOKEN=$(pass "pagerduty/rubbernecker_api_token")

SECRETS=$(mktemp secrets.yml.XXXXXX)
trap 'rm "${SECRETS}"' EXIT

cat > "${SECRETS}" << EOF
---
pivotal_tracker_project_id: 1275640
pivotal_tracker_api_token: ${PIVOTAL_TRACKER_API_TOKEN}
pagerduty_authtoken: ${PAGERDUTY_AUTHTOKEN}
EOF

aws s3 cp "${SECRETS}" "s3://gds-paas-${DEPLOY_ENV}-state/rubbernecker-secrets.yml"
