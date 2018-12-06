ARCH ?= amd64
TAG ?= latest
BASE ?= alpine

.PHONY: radixdlt-nginx-all radixdlt-core-all
radixdlt-nginx-all radixdlt-core-all:
	@$(MAKE) ARCH=amd64 TAG=$(TAG) BASE=$(BASE) $(subst -all,,$@)
	@$(MAKE) ARCH=arm32v6 TAG=$(TAG) BASE=$(BASE) $(subst -all,,$@)
	@$(MAKE) ARCH=arm64v8 TAG=$(TAG) BASE=$(BASE) $(subst -all,,$@)

# docker manifest needs "experimental": "enabled" added to your ~/.docker/config.json
.PHONY: radixdlt-nginx-all-push radixdlt-core-all-push
radixdlt-nginx-all-push radixdlt-core-all-push:
	@$(MAKE) ARCH=amd64 TAG=$(TAG) BASE=$(BASE) $(subst -all,,$@)
	@$(MAKE) ARCH=arm32v6 TAG=$(TAG) BASE=$(BASE) $(subst -all,,$@)
	@$(MAKE) ARCH=arm64v8 TAG=$(TAG) BASE=$(BASE) $(subst -all,,$@)
	docker manifest create --amend radixdlt/$(subst -all-push,,$@):$(TAG) \
		radixdlt/$(subst -all-push,,$@):$(TAG)-amd64 \
		radixdlt/$(subst -all-push,,$@):$(TAG)-arm32v6 \
		radixdlt/$(subst -all-push,,$@):$(TAG)-arm64v8
	docker manifest push --purge radixdlt/$(subst -all-push,,$@):$(TAG)

.PHONY: radixdlt-nginx radixdlt-core
radixdlt-nginx radixdlt-core:
	docker build \
		-t radixdlt/$@:$(TAG)-$(ARCH) \
		--build-arg ARCH=$(ARCH) \
		-f $@/Dockerfile.$(BASE) \
		./$@

.PHONY: radixdlt-nginx-push radixdlt-core-push
radixdlt-nginx-push radixdlt-core-push:
	docker push radixdlt/$(subst -push,,$@):$(TAG)-$(ARCH)
