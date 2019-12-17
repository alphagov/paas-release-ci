#!/bin/bash

set -eu

export PASSWORD_STORE_DIR=${ZENDESK_PASSWORD_STORE_DIR}

ZENDESK_USER="$(pass zendesk/api_user)"
ZENDESK_TOKEN="$(pass zendesk/api_key)"

aws s3 cp - "s3://gds-paas-${DEPLOY_ENV}-state/zendesk-secrets.yml" << EOF
---
zendesk_user: ${ZENDESK_USER}
zendesk_token: ${ZENDESK_TOKEN}
EOF
