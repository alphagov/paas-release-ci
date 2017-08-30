#!/bin/bash

if [ "${SKIP_AWS_CREDENTIAL_VALIDATION:-}" == "true" ]  ; then
  exit 0
fi

if [ -z "$AWS_SESSION_TOKEN" ]; then
  echo "No temporary AWS credentials found, please run create_sts_token.sh"
  exit 255;
fi

if [ -z "$AWS_ACCOUNT" ]; then
  echo "No AWS_ACCOUNT specified, please populate the environment variable"
  exit 255;
fi

aws iam get-user > /dev/null 2>&1
if [[ $? != 0 ]]; then
  echo "Current AWS credentials are invalid, please refresh them using create_sts_token.sh"
  exit 255;
fi

check_aws_account_used() {
  required_account="${1}"
  account_alias=$(aws iam list-account-aliases | grep gov-paas | tr -d '" ')

  if [[ "${account_alias}" != "gov-paas-${required_account}" ]]; then
    echo "Required AWS account is ${required_account}, but your aws-cli is using keys for ${account_alias}"
    exit 1
  fi
}

check_aws_account_used "${AWS_ACCOUNT}"
