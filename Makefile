#!/usr/bin/env make
#SHELL = sh -xv

ENV_PATH := $(shell pwd)/.env

ifneq (,$(wildcard $(ENV_PATH)))
    include $(ENV_PATH)
    export
endif

TAG := ${CI_REGISTRY}/${GITHUB_REPOSITORY}/s3-backup:latest

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: login
login:
	docker login $(CI_REGISTRY)

.PHONY: push
push:
	make login
	docker push $(TAG)

.PHONY: build
build:
	docker build --file="$(shell pwd)/.docker/aws-cli/Dockerfile" --tag $(TAG) --progress=plain .

.PHONY: shell
shell:
	docker run --rm -ti -v "$(shell pwd)/.docker/aws-cli/etc/backup.sh:/backup.sh" --entrypoint=/bin/bash $(TAG)
