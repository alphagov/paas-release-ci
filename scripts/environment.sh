#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
FLY_DIR=$(cd "${SCRIPT_DIR}/../bin" && pwd)

hashed_password() {
  echo "$1" | shasum -a 256 | base64 | head -c 32
}

if [ -z "${DEPLOY_ENV:-}" ]; then
  echo "Must specify DEPLOY_ENV as environment variable" 1>&2
  exit 1
fi

AWS_ACCOUNT=${AWS_ACCOUNT:-dev}

CONCOURSE_URL="${CONCOURSE_URL:-https://concourse.${SYSTEM_DNS_ZONE_NAME}}"
FLY_TARGET=${FLY_TARGET:-$DEPLOY_ENV}
FLY_CMD="${FLY_DIR}/fly"

if [ -z "${DOCKERHUB_USERNAME:-}" ]; then
  DOCKERHUB_USERNAME=$(pass dockerhub/ci/id)
fi

if [ -z "${DOCKERHUB_PASSWORD:-}" ]; then
  DOCKERHUB_PASSWORD=$(pass dockerhub/ci/password)
fi

cat <<EOF
export AWS_ACCOUNT=${AWS_ACCOUNT}
export DEPLOY_ENV=${DEPLOY_ENV}
export CONCOURSE_URL=${CONCOURSE_URL}
export FLY_CMD=${FLY_CMD}
export FLY_TARGET=${FLY_TARGET}
export DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME}
export DOCKERHUB_PASSWORD=${DOCKERHUB_PASSWORD}
EOF
