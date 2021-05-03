# The node-runner project for RadixDLT Core

This repo contains configuration files needed for running RadixDLT nodes using nginx as a reverse proxy.

# Artifacts for standalone nginx 
For node runners that do not want to use the radixdlt/radixdlt-nginx there is a script that will generate
the configuration for Archive and Fullnodes.

```shell
bash generate_artifact.sh
```
Will generate:
* radixdlt-nginx-archive-conf.zip
* radixdlt-nginx-fullnode-conf.zip

Both artifacts are published as part of the release
