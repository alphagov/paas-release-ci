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
	$(eval export ENABLE_DESTROY=true)
	$(eval export UNPAUSE_PIPELINES=false)
	$(eval export SYSTEM_DNS_ZONE_NAME=${DEPLOY_ENV}.dev.cloudpipeline.digital)
	$(eval export CF_API=https://api.${SYSTEM_DNS_ZONE_NAME})
	$(eval export CF_APPS_DOMAIN=${DEPLOY_ENV}.dev.cloudpipelineapps.digital)
	@true

ci: globals ## Work on the ci account
	$(eval export MAKEFILE_ENV_TARGET=ci)
	$(eval export DEPLOY_ENV=build)
	$(eval export AWS_ACCOUNT=ci)
	$(eval export SYSTEM_DNS_ZONE_NAME=${DEPLOY_ENV}.ci.cloudpipeline.digital)
	$(eval export CONCOURSE_ATC_PASSWORD_PASS_FILE=ci_deployments/build/concourse_password)
	$(eval export CF_API=https://api.cloud.service.gov.uk)
	$(eval export CF_APPS_DOMAIN=cloudapps.digital)
	@true

.PHONY: upload-cf-cli-secrets
upload-cf-cli-secrets: check-env-vars ## Decrypt and upload CF CLI credentials to S3
	$(eval export CF_CLI_PASSWORD_STORE_DIR?=${HOME}/.paas-pass)
	$(if ${AWS_ACCOUNT},,$(error Must set environment to dev/ci))
	$(if ${CF_CLI_PASSWORD_STORE_DIR},,$(error Must pass CF_CLI_PASSWORD_STORE_DIR=<path_to_password_store>))
	$(if $(wildcard ${CF_CLI_PASSWORD_STORE_DIR}),,$(error Password store ${CF_CLI_PASSWORD_STORE_DIR} does not exist))
	@scripts/upload-cf-cli-secrets.sh

.PHONY: upload-compose-secrets
upload-compose-secrets: check-env-vars ## Decrypt and upload Compose credentials to S3
	$(eval export COMPOSE_PASSWORD_STORE_DIR?=${HOME}/.paas-pass)
	$(if ${AWS_ACCOUNT},,$(error Must set environment to dev/ci))
	$(if ${COMPOSE_PASSWORD_STORE_DIR},,$(error Must pass COMPOSE_PASSWORD_STORE_DIR=<path_to_password_store>))
	$(if $(wildcard ${COMPOSE_PASSWORD_STORE_DIR}),,$(error Password store ${COMPOSE_PASSWORD_STORE_DIR} does not exist))
	@scripts/upload-compose-secrets.sh

.PHONY: upload-deskpro-secrets
upload-deskpro-secrets: check-env-vars ## Decrypt and upload DeskPro credentials to S3
	$(eval export DESKPRO_PASSWORD_STORE_DIR?=${HOME}/.paas-pass)
	$(if ${DESKPRO_PASSWORD_STORE_DIR},,$(error Must pass DESKPRO_PASSWORD_STORE_DIR=<path_to_password_store>))
	$(if $(wildcard ${DESKPRO_PASSWORD_STORE_DIR}),,$(error Password store ${DESKPRO_PASSWORD_STORE_DIR} does not exist))
	@scripts/upload-deskpro-secrets.sh

.PHONY: upload-rubbernecker-secrets
upload-rubbernecker-secrets: check-env-vars ## Decrypt and upload DeskPro credentials to S3
	$(eval export RUBBERNECKER_PASSWORD_STORE_DIR?=${HOME}/.paas-pass)
	$(if ${RUBBERNECKER_PASSWORD_STORE_DIR},,$(error Must pass RUBBERNECKER_PASSWORD_STORE_DIR=<path_to_password_store>))
	$(if $(wildcard ${RUBBERNECKER_PASSWORD_STORE_DIR}),,$(error Password store ${RUBBERNECKER_PASSWORD_STORE_DIR} does not exist))
	@scripts/upload-rubbernecker-secrets.sh

.PHONY: pipelines
pipelines: ## Upload setup pipelines to concourse
	@scripts/deploy-setup-pipelines.sh

.PHONY: boshrelease-pipelines
boshrelease-pipelines: ## Upload boshrelease pipelines to concourse
	@scripts/build-boshrelease-pipelines.sh

.PHONY: app-deployment-pipelines
app-deployment-pipelines: ## Upload app deployment pipelines to concourse
	@scripts/build-app-deployment-pipelines.sh

.PHONY: integration-test-pipelines
integration-test-pipelines: ## Upload integration test pipelines to concourse
	@scripts/integration-test-pipelines.sh

.PHONY: plain-pipelines
plain-pipelines: ## Upload plain pipelines to concourse
	@scripts/build-plain-pipelines.sh

showenv: ## Display environment information
	@scripts/environment.sh

## Testing tasks

.PHONY: test
test: spec lint_shellcheck lint_terraform lint_yaml lint_concourse

.PHONY: spec
spec:
	cd scripts && go test

.PHONY: lint_shellcheck
lint_shellcheck:
	find . -name '*.sh' | xargs shellcheck

.PHONY: lint_terraform
lint_terraform:
	@scripts/lint_terraform.sh

.PHONY: lint_yaml
lint_yaml:
	find . -name '*.yml' | xargs yamllint -c yamllint.yml

.PHONY: lint_concourse
lint_concourse:
	./scripts/pipecleaner.py --fatal-warnings pipelines/*.yml
