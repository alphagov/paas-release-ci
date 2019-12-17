help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

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
