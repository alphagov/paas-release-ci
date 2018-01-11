#!/bin/sh
set -eu

TMPDIR=${TMPDIR:-/tmp}
TF_DATA_DIR=$(mktemp -d "${TMPDIR}/terraform_lint.XXXXXX")
trap 'rm -r "${TF_DATA_DIR}"' EXIT

export TF_DATA_DIR
export TF_VAR_deploy_env=test
export TF_VAR_releases_bucket_name=test
export TF_VAR_releases_blobs_bucket_name=test

cd terraform
terraform init >/dev/null
terraform validate >/dev/null
terraform fmt -check -diff
