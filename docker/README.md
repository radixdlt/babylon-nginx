# Pre-requisites

* The `make` (gnumake) tool installed
* Recently new `docker` dist (with `docker manifest` support)

# Building Images

The following example is for building the `radixdlt-nginx` image although all images in [examples/docker](https://github.com/radixdlt/node-runner/blob/master/example/docker) can be built similarly.

## Build Image for ALL Architectures

```shell
make radixdlt-nginx-all
```

## Build Image for single Arch

```shell
make ARCH=amd64 radixdlt-nginx
```

## Push Images

**NOTE**: You need to be logged into Dockerhub in order to do this.

```shell
make ARCH=amd64 radixdlt-nginx-all-push
```
