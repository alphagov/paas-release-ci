#!/bin/bash
set -eu

action="$1"
pipeline="${2:-all}"

SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)

# shellcheck disable=SC2091
$("${SCRIPTS_DIR}/environment.sh")
"${SCRIPTS_DIR}/fly_sync_and_login.sh"

if [ "$pipeline" != "all" ]; then
  $FLY_CMD -t "${FLY_TARGET}" "${action}-pipeline" -p "$pipeline"
  exit 0
fi

pipelines=$($FLY_CMD -t "${FLY_TARGET}" pipelines --json | jq -r '.[].name')
for pipeline in $pipelines; do
  if [ "${pipeline}" != "create-bosh-concourse" ]; then
    $FLY_CMD -t "${FLY_TARGET}" "${action}-pipeline" -p "$pipeline"
  fi
done
