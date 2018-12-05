ARCH ?= amd64
TAG ?= latest

.PHONY: radixdlt-nginx-all
radixdlt-nginx-all:
	@$(MAKE) ARCH=amd64 TAG=$(TAG) radixdlt-nginx
	@$(MAKE) ARCH=arm32v6 TAG=$(TAG) radixdlt-nginx
	@$(MAKE) ARCH=arm64v8 TAG=$(TAG) radixdlt-nginx

# docker manifest needs "experimental": "enabled" added to your ~/.docker/config.json
.PHONY: radixdlt-nginx-all-push
radixdlt-nginx-all-push:
	@$(MAKE) ARCH=amd64 TAG=$(TAG) radixdlt-nginx-push
	@$(MAKE) ARCH=arm32v6 TAG=$(TAG) radixdlt-nginx-push
	@$(MAKE) ARCH=arm64v8 TAG=$(TAG) radixdlt-nginx-push
	docker manifest create --amend radixdlt/radixdlt-nginx:$(TAG) \
		radixdlt/radixdlt-nginx:$(TAG)-amd64 \
		radixdlt/radixdlt-nginx:$(TAG)-arm32v6 \
		radixdlt/radixdlt-nginx:$(TAG)-arm64v8
	docker manifest push --purge radixdlt/radixdlt-nginx:$(TAG)

.PHONY: radixdlt-nginx
radixdlt-nginx:
	docker build \
		-t radixdlt/radixdlt-nginx:$(TAG)-$(ARCH) \
		--build-arg ARCH=$(ARCH) \
		--build-arg TAG=$(TAG) \
		-f radixdlt-nginx/Dockerfile.alpine \
		./radixdlt-nginx

.PHONY: radixdlt-nginx-push
radixdlt-nginx-push:
	docker push radixdlt/radixdlt-nginx:$(TAG)-$(ARCH)
