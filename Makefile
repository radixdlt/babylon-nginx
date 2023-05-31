all:
    $(eval GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD | sed 's/\//-/g'))
    $(eval GIT_COMMIT=$(shell git log -1 --format=%h ))
    DOCKER_TAG ?= $(GIT_BRANCH)-$(GIT_COMMIT)
    REGISTRY ?= docker.io/radixdlt


.PHONY: build
build:
	docker build \
		-t $(REGISTRY)/private-babylon-nginx:$(DOCKER_TAG) \
		-f Dockerfile.alpine .

.PHONY: publish
publish: build
	docker push $(REGISTRY)/private-babylon-nginx:$(DOCKER_TAG)

