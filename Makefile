#!/usr/bin/env make
SHELL = sh -xv

ENV_PATH := $(shell pwd)/.env

ifneq (,$(wildcard $(ENV_PATH)))
    include $(ENV_PATH)
    export
endif

TAG := ${CI_REGISTRY}/renaissance7/infrastructure/backup-media:latest

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: login
login:
	docker login $(DOCKER_REGISTRY_URL)

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

BUILD_IMAGE_TAG=registry.gitlab.com/renaissance7/s3-backup/docker-compose:latest
.PHONY: build-images
build-images:
	docker pull docker/compose:latest
	docker tag docker/compose:latest $(BUILD_IMAGE_TAG)
	docker push $(BUILD_IMAGE_TAG)