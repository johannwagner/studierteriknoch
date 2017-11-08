# import deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`
dpl ?= deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

# grep the version from the mix file
VERSION=$(shell ./version.sh)


# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help build build-nc

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# DOCKER TASKS
# Build the container
build: ## Build the container
	npm run build
	docker build -t $(APP_NAME) .

build-nc: ## Build the container without caching
	npm run build
	docker build --no-cache -t $(APP_NAME) .

run: ## Run container on port 80 and 443
	docker run -i -t --rm -p=80:80 -p=443:443 -v "$(SSL_CRT)":/fullchain.pem -v "$(SLL_PRIV)":/privkey.pem --name="$(APP_NAME)" $(APP_NAME)

cert:
	mkdir cert

cert/privkey.pem cert/test.cert.csr: cert
	( cd cert && openssl req -new > test.cert.csr	)

cert/test.priv: cert/privkey.pem
	( cd cert && openssl rsa -in privkey.pem -out test.priv )

cert/test.crt: cert/privkey.pem cert/test.cert.csr
	( cd cert && openssl x509 -in test.cert.csr -out test.crt -req -signkey test.priv -days 90 )

self-signed: cert/privkey.pem cert/test.cert.csr cert/test.priv cert/test.crt ## Generate self-signed certificates  - DO NOT USE IN PRODUCTION!!!

run-self-signed: self-signed ## Run container on port 80 and 443 with self-signed certificates
	docker run -i -t --rm -p=80:80 -p=443:443 -v $(PWD)/cert/test.crt:/fullchain.pem -v $(PWD)/cert/test.priv:/privkey.pem --name="$(APP_NAME)" $(APP_NAME)


up: build run ## Run container on port configured in `config.env` (Alias to run)

stop: ## Stop and remove a running container
	docker stop $(APP_NAME); docker rm $(APP_NAME)

release: build-nc publish ## Make a release by building and publishing the `{version}` ans `latest` tagged containers

# Docker publish
publish: publish-latest publish-version ## Publish the `{version}` ans `latest` tagged containers

publish-latest: tag-latest ## Publish the `latest` taged container
	@echo 'publish latest to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):latest

publish-version: tag-version ## Publish the `{version}` taged container
	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

# Docker tagging
tag: tag-latest tag-version ## Generate container tags for the `{version}` ans `latest` tags

tag-latest: ## Generate container `{version}` tag
	@echo 'create tag latest'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):latest

tag-version: ## Generate container `latest` tag
	@echo 'create tag $(VERSION)'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

version: ## Output the current version
	@echo $(VERSION)
