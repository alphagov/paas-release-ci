help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

check-env-vars:
	$(if ${DEPLOY_ENV},,$(error Must pass DEPLOY_ENV=<name>))

PASSWORD_STORE_DIR?=${HOME}/.paas-pass
globals:
	$(eval export PASSWORD_STORE_DIR=${PASSWORD_STORE_DIR})
	@true

dev: globals check-env-vars ## Work on the dev account
	$(eval export MAKEFILE_ENV_TARGET=dev)
	$(eval export AWS_ACCOUNT=dev)
	$(eval export SYSTEM_DNS_ZONE_NAME=${DEPLOY_ENV}.dev.cloudpipeline.digital)
	@true

ci: globals ## Work on the ci account
	$(eval export MAKEFILE_ENV_TARGET=ci)
	$(eval export DEPLOY_ENV=build)
	$(eval export AWS_ACCOUNT=ci)
	$(eval export ENABLE_AUTO_TRIGGER=true)
	$(eval export SYSTEM_DNS_ZONE_NAME=${DEPLOY_ENV}.ci.cloudpipeline.digital)
	$(eval export CONCOURSE_ATC_PASSWORD_PASS_FILE=ci_deployments/build/concourse_password)
	@true

.PHONY: pipelines
pipelines: ## Upload setup pipeline to concourse
	@scripts/deploy-setup-pipeline.sh

showenv: ## Display environment information
	@scripts/environment.sh
