.PHONY: help

ENVIRONMENT ?= prod
# Include only if file exists:
-include ./ansible/environments/${ENVIRONMENT}/default.env
-include .env

.EXPORT_ALL_VARIABLES:
PROJECT ?= fabaccess-cb
# ansible playbook flags:
TAGS ?= ""
LIMIT ?= ""

help: ## Show help for this Makefile
	@grep -Eh '^[a-zA-Z_-]+:.*?## .*$$' ${MAKEFILE_LIST} | sort | awk 'BEGIN {FS = ":.*? ##"}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Generate local config.
# Executed only when starting `make up` the first time:
.env:
	cp ./ansible/environments/${ENVIRONMENT}/default.env .env

up: .env ## Start local dev environment with docker-compose
	@docker-compose -p "${PROJECT}" up --force-recreate

down: .env ## Stop local dev environment with docker-compose
	@docker-compose -p "${PROJECT}" down -v

ansible-requirements: ## Install ansible requirements via ansible-galaxy.
	ansible-galaxy collection install -r ./ansible/requirements.yaml
	ansible-galaxy role install -r ./ansible/requirements.yaml

ansible-facts: ## Show facts for a host; e.g. make ansible-facts -e HOST=oklab
	ansible -i ./ansible/environments/${ENVIRONMENT} ${HOST} -m setup

setup: ## Setup fabaccess hosts with ansible; e.g. make setup -e TAGS=common
	ansible-playbook \
		-vv \
		--vault-id "${ENVIRONMENT}@prompt" \
		-e "@./ansible/environments/${ENVIRONMENT}/secrets.yaml" \
		-i "./ansible/environments/${ENVIRONMENT}" \
		--tags "${TAGS}" \
		--limit "${LIMIT}" \
		ansible/setup.yaml

deploy: ## Deploy fabaccess with ansible.
	ansible-playbook \
		-vv \
		--vault-id "${ENVIRONMENT}@prompt" \
		-e "@./ansible/environments/${ENVIRONMENT}/secrets.yaml" \
		-i "./ansible/environments/${ENVIRONMENT}" \
		ansible/deploy.yaml

secrets-edit: ## Edit secrets with ansible-vault.
	ansible-vault edit --vault-id "${ENVIRONMENT}@prompt" "./ansible/environments/${ENVIRONMENT}/secrets.yaml"

secrets-encrypt: ## Encrypt secrets with ansible-vault.
	ansible-vault encrypt --vault-id "${ENVIRONMENT}@prompt" "./ansible/environments/${ENVIRONMENT}/secrets.yaml"

secrets-decrypt: ## Decrypt secrets with ansible-vault.
	ansible-vault decrypt --vault-id "${ENVIRONMENT}@prompt" "./ansible/environments/${ENVIRONMENT}/secrets.yaml"