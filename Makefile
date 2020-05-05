help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

check-env-vars:
	$(if ${DEPLOY_ENV},,$(error Must pass DEPLOY_ENV=<name>))

PASSWORD_STORE_DIR?=${HOME}/.paas-pass
CF_DEPLOY_ENV?=${DEPLOY_ENV}

globals:
	$(eval export PASSWORD_STORE_DIR=${PASSWORD_STORE_DIR})
	$(eval export CF_DEPLOY_ENV=${CF_DEPLOY_ENV})
	@true

dev: globals check-env-vars ## Work on the dev account
	$(eval export MAKEFILE_ENV_TARGET=dev)
	$(eval export AWS_ACCOUNT=dev)
	$(eval export ENABLE_DESTROY=true)
	$(eval export UNPAUSE_PIPELINES=false)
	$(eval export SYSTEM_DNS_ZONE_NAME=${DEPLOY_ENV}.dev.cloudpipeline.digital)
	$(eval export CF_APPS_DOMAIN=$(or $(CF_APPS_DOMAIN),${CF_DEPLOY_ENV}.dev.cloudpipelineapps.digital))
	$(eval export CF_SYSTEM_DOMAIN=$(or $(CF_SYSTEM_DOMAIN),${CF_DEPLOY_ENV}.dev.cloudpipeline.digital))
	@true

ci: globals ## Work on the ci account
	$(eval export MAKEFILE_ENV_TARGET=ci)
	$(eval export DEPLOY_ENV=build)
	$(eval export AWS_ACCOUNT=ci)
	$(eval export SYSTEM_DNS_ZONE_NAME=${DEPLOY_ENV}.ci.cloudpipeline.digital)
	$(eval export CONCOURSE_WEB_PASSWORD_PASS_FILE=ci_deployments/build/concourse_password)
	$(eval export CF_APPS_DOMAIN=cloudapps.digital)
	$(eval export CF_SYSTEM_DOMAIN=cloud.service.gov.uk)
	@true

.PHONY: upload-cf-cli-secrets
upload-cf-cli-secrets: check-env-vars require-credhub ## Decrypt and upload CF CLI credentials to Credhub
	$(eval export CF_CLI_PASSWORD_STORE_DIR?=${HOME}/.paas-pass)
	$(if ${AWS_ACCOUNT},,$(error Must set environment to dev/ci))
	$(if ${CF_CLI_PASSWORD_STORE_DIR},,$(error Must pass CF_CLI_PASSWORD_STORE_DIR=<path_to_password_store>))
	$(if $(wildcard ${CF_CLI_PASSWORD_STORE_DIR}),,$(error Password store ${CF_CLI_PASSWORD_STORE_DIR} does not exist))
	@scripts/upload-secrets/upload-cf-cli-secrets.rb

.PHONY: upload-aiven-secrets
upload-aiven-secrets: check-env-vars require-credhub ## Decrypt and upload Aiven credentials to Credhub
	$(eval export AIVEN_PASSWORD_STORE_DIR?=${HOME}/.paas-pass)
	$(if ${AWS_ACCOUNT},,$(error Must set environment to dev/ci))
	$(if ${AIVEN_PASSWORD_STORE_DIR},,$(error Must pass _PASSWORD_STORE_DIR=<path_to_password_store>))
	$(if $(wildcard ${AIVEN_PASSWORD_STORE_DIR}),,$(error Password store ${AIVEN_PASSWORD_STORE_DIR} does not exist))
	@scripts/upload-secrets/upload-aiven-secrets.rb

.PHONY: upload-zendesk-secrets
upload-zendesk-secrets: check-env-vars require-credhub ## Decrypt and upload Zendesk credentials to Credhub
	$(eval export ZENDESK_PASSWORD_STORE_DIR?=${HOME}/.paas-pass)
	$(if ${ZENDESK_PASSWORD_STORE_DIR},,$(error Must pass ZENDESK_PASSWORD_STORE_DIR=<path_to_password_store>))
	$(if $(wildcard ${ZENDESK_PASSWORD_STORE_DIR}),,$(error Password store ${ZENDESK_PASSWORD_STORE_DIR} does not exist))
	@scripts/upload-secrets/upload-zendesk-secrets.rb

.PHONY: upload-rubbernecker-secrets
upload-rubbernecker-secrets: check-env-vars require-credhub ## Decrypt and upload Rubbernecker credentials to Credhub
	$(eval export RUBBERNECKER_PASSWORD_STORE_DIR?=${HOME}/.paas-pass)
	$(if ${RUBBERNECKER_PASSWORD_STORE_DIR},,$(error Must pass RUBBERNECKER_PASSWORD_STORE_DIR=<path_to_password_store>))
	$(if $(wildcard ${RUBBERNECKER_PASSWORD_STORE_DIR}),,$(error Password store ${RUBBERNECKER_PASSWORD_STORE_DIR} does not exist))
	@scripts/upload-secrets/upload-rubbernecker-secrets.rb

.PHONY: upload-hackmd-secrets
upload-hackmd-secrets: check-env-vars require-credhub ## Decrypt and upload Hackmd credentials to Credhub
	$(eval export HACKMD_PASSWORD_STORE_DIR?=${HOME}/.paas-pass)
	$(if ${HACKMD_PASSWORD_STORE_DIR},,$(error Must pass HACKMD_PASSWORD_STORE_DIR=<path_to_password_store>))
	$(if $(wildcard ${HACKMD_PASSWORD_STORE_DIR}),,$(error Password store ${HACKMD_PASSWORD_STORE_DIR} does not exist))
	@scripts/upload-secrets/upload-hackmd-secrets.rb

.PHONY: upload-github-secrets
upload-github-secrets: check-env-vars require-credhub ## Decrypt and upload Github credentials to Credhub
	$(eval export GITHUB_PASSWORD_STORE_DIR?=${HOME}/.paas-pass)
	$(if ${GITHUB_PASSWORD_STORE_DIR},,$(error Must pass GITHUB_PASSWORD_STORE_DIR=<path_to_password_store>))
	$(if $(wildcard ${GITHUB_PASSWORD_STORE_DIR}),,$(error Password store ${GITHUB_PASSWORD_STORE_DIR} does not exist))
	@scripts/upload-secrets/upload-github-secrets.rb

.PHONY: upload-slack-secrets
upload-slack-secrets: check-env-vars require-credhub ## Decrypt and upload Github credentials to Credhub
	$(eval export SLACK_PASSWORD_STORE_DIR?=${HOME}/.paas-pass)
	$(if ${SLACK_PASSWORD_STORE_DIR},,$(error Must pass SLACK_PASSWORD_STORE_DIR=<path_to_password_store>))
	$(if $(wildcard ${SLACK_PASSWORD_STORE_DIR}),,$(error Password store ${SLACK_PASSWORD_STORE_DIR} does not exist))
	@scripts/upload-secrets/upload-slack-secrets.rb


.PHONY: upload-dockerhub-secrets
upload-dockerhub-secrets: check-env-vars require-credhub ## Decrypt and upload Github credentials to Credhub
	$(eval export DOCKERHUB_PASSWORD_STORE_DIR?=${HOME}/.paas-pass)
	$(if ${DOCKERHUB_PASSWORD_STORE_DIR},,$(error Must pass DOCKERHUB_PASSWORD_STORE_DIR=<path_to_password_store>))
	$(if $(wildcard ${DOCKERHUB_PASSWORD_STORE_DIR}),,$(error Password store ${DOCKERHUB_PASSWORD_STORE_DIR} does not exist))
	@scripts/upload-secrets/upload-dockerhub-secrets.rb

.PHONY: upload-all-secrets
upload-all-secrets: upload-cf-cli-secrets upload-aiven-secrets upload-zendesk-secrets upload-rubbernecker-secrets upload-hackmd-secrets upload-github-secrets upload-slack-secrets upload-dockerhub-secrets

.PHONY: pipelines
pipelines: ## Upload setup pipelines to concourse
	@scripts/deploy-setup-pipelines.sh

.PHONY: boshrelease-pipelines
boshrelease-pipelines: ## Upload boshrelease pipelines to concourse
	@scripts/build-boshrelease-pipelines.sh

.PHONY: integration-test-pipelines
integration-test-pipelines: ## Upload integration test pipelines to concourse
	@scripts/integration-test-pipelines.sh

.PHONY: plain-pipelines
plain-pipelines: ## Upload plain pipelines to concourse
	@scripts/plain-pipelines.sh

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
	pipecleaner pipelines/*.yml pipelines/**/*.yml


.PHONY: pause-all-pipelines
pause-all-pipelines: ## Pause all pipelines so that create-bosh-concourse can be run safely.
	./scripts/pause-pipelines.sh pause

.PHONY: unpause-all-pipelines
unpause-all-pipelines: ## Unpause all pipelines after running create-bosh-concourse
	./scripts/pause-pipelines.sh unpause

.PHONY: credhub
credhub:
	@./scripts/credhub-shell.sh

require-credhub:
	$(if ${CREDHUB_SHELL},,$(error Must be inside credhub shell. Run `make {env} credhub`))
