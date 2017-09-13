#!/bin/bash
set -euo pipefail

# Required env vars
# CONCOURSE_URL
# CONCOURSE_ATC_USER
# CONCOURSE_ATC_PASSWORD
# FLY_CMD
# FLY_TARGET

FLY_CMD_URL="${CONCOURSE_URL}/api/v1/cli?arch=amd64&platform=$(uname | tr '[:upper:]' '[:lower:]')"
echo "Downloading fly command..."
if [ -f "$FLY_CMD" ]; then
  timestamp_flag=1
fi
curl "$FLY_CMD_URL" -# -L -f ${timestamp_flag:+-z "$FLY_CMD"} -o "$FLY_CMD" -u "${CONCOURSE_ATC_USER}:${CONCOURSE_ATC_PASSWORD}"
chmod +x "$FLY_CMD"

echo "Doing fly login"
$FLY_CMD -t "${FLY_TARGET}" login --concourse-url "${CONCOURSE_URL}" -u "${CONCOURSE_ATC_USER}" -p "${CONCOURSE_ATC_PASSWORD}"

echo "Doing fly sync"
$FLY_CMD -t "${FLY_TARGET}" sync
