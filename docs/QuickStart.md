# Introduction

This is a QuickStart guide to running a RadixDLT Node on your computer primarily aimed for non-technical users.
The following steps will be covered:

1. Installing [Docker](https://www.docker.com/) 
1. Installing [Docker Compose](https://docs.docker.com/compose/) *(Linux only)*
2. Creating a `docker-compose.yml` configuration file
3. Launching your RadixDLT Node

# Pre-requisites

## Hardware

Your targeted node should have **at least**:

* 2 CPU cores
* 8 GB memory
* 256 GB disk

### Note

1. The actual disk size requirement will grow over time as the ledger grows.
1. Low powered devices are not targeted for this release of the Node runner software.

## Software

You can run a RadixDLT node on any operative system that supports Docker and Docker Compose, including:

* Linux
* MacOS X
* Windows 10

## Forwarding Incoming Traffic to your Node

You can skip this if your node is directly connected to the internet (has a public IP address).

If you are behind a firewall/NAT (typically `192.168.*`, `10.*` IP address), then you need to forward traffic to your node including:

1. Incoming Gossip traffic on **TCP port 20000**. 
1. Incoming Gossip traffic on **UDP port 20000**. 
1. Incoming HTTPS traffic on **TCP port 443**.

Furthermore, you need to make sure your DHCP server is assigning a **static IP address** to your node, otherwise forwarded traffic will fail if your node's IP address changes later on.

These are rather straight forward changes that most consumer Routers support. Please refer to the user guide of your Router for how to do this.

**NOTE**: These ports might change for *Beta* - please check back later.

# Installing Docker

Please refer to the official installation guide for [Docker CE](https://www.docker.com/community-edition).
 

# Installing Docker Compose

Docker Compose is bundled with Docker CE for the Mac and Windows versions.

You only need to install [Docker Compose](https://docs.docker.com/compose/install/) separately if running on Linux.

# Creating a docker-compose.yml configuration file

The RadixDLT software stack is composed of a set of specialised docker images, with different roles. The minimal (basic) radixdlt system contains the following two components (docker images):

1. `radixdlt.azurecr.io/radixdlt/radixdlt-core:latest-alpha`
1. `radixdlt/radixdlt-nginx:latest-alpha`

Your `docker-compose.yml` determines the software components you will run. In perticular the following is specified:

1. One or more Docker images to download and start
2. The configuration (seenvironment variables) for each Docker image
3. Persistent data volumes - that survive restarts and upgrades.

Start with this docker compose file:

```yaml
{% include_relative basic-node.yml %}
```

1. Create a directory on your computer for storing docker compose files (e.g. `radixdlt`).
2. Use your favorite text editor to create the `basic-node.yml`.
3. Copy-and-paste the content above.

You can also download the latest version of this file [basic-node.yml](https://github.com/radixdlt/node-runner/blob/master/docs/basic-node.yml).

# Launching your Node

Open up Terminal (Mac/Linux) or CMD on Windows.
Navigate to the directory that you put your `docker-composer.yml` file in.
Launch the Docker containers with:

```shell
cd ~/radixdlt
docker-compose -f basic-node.yml up -d
```

If successful, it should pull down and look something like this when completed:

```shell
Pulling core (radixdlt.azurecr.io/radixdlt/radixdlt-core:latest-alpha)...
latest-alpha: Pulling from radixdlt/radixdlt-core
...
Digest: sha256:d7f31770d1060d20ffd8f21365158937e893e4d3ce5ccdc089d1d11bbf26d4e0
Status: Downloaded newer image for radixdlt.azurecr.io/radixdlt/radixdlt-core:latest-alpha
Pulling nginx (radixdlt/radixdlt-nginx:latest-alpha)...
latest-alpha: Pulling from radixdlt/radixdlt-nginx
...
Digest: sha256:0f38c6706e2a2e6ff20e0167d266998dc4d2813e1b12ede644cfd97c9127161c
Status: Downloaded newer image for radixdlt/radixdlt-nginx:latest-alpha
Creating radixdlt_nginx_1 ... done
Creating radixdlt_core_1  ... done
```

Check that you have two (`radixdlt_nginx_1` and `radixdlt_core_1`) Docker containers with:

```shell
docker ps
```

Make note and write down the `admin` password - its written in the `radixdlt_nginx_1` container logs the **first time** it starts: 

```shell
docker logs radixdlt_nginx_1
```

This password is used for accessing administrative APIs on your node.
If you forget, you can re-generate this at any time by setting the `WIPE_ADMIN_PASSWORD` environment variable.

You can also check if the Node is up and running here: https://localhost/api/system

**NOTE**: Since it is a self-signed certificate browsers are expected to warn you that this link is unsafe - you can disregard this for Alpha/Beta.

If running correctly you should get a bunch of metrics - it should look something like this:

```
{"ledger":{"processed":0,"latency":{"path":0,"persist":0},"stored":3,"checksum":2193713224449319881,"processing":0,"faults":{"tears":0,"stitched":0},"storing":0},"agent":{"protocol":100,"name":"/Radix:/2300000","version":2300000},"hid":{"serializer":"EUID","value":"13115213306523712699347341883"},"period":0,"memory":{"total":122683392,"max":466092032,"free":61252608},"commitment":{"serializer":"HASH","value":"0000000000000000000000000000000000000000000000000000000000000000"},"serializer":-1833998801,"clock":0,"processors":4,"version":100,"shards":{"high":9223372036854775807,"low":-9223372036854775808},"port":20000,"messages":{"processed":0,"processing":0},"events":{"processed":27,"processing":0},"key":{"serializer":"BASE64","value":"AtadBccJwmoeY70gWLM0hQyTJtbhROrupp9A4/DHzXMa"}}
```

After around a minute or so, your new Node should also have found some Peers - to check it’s peer grouping, look here: https://localhost/api/network/peers

If it is working correctly, you should have around a full browser page of peer information that looks something like this:

```
{"serializer":"BASE64","value":"AtvDaWQgPRftFxpybWD/1Yyt3w5UPI510bp6+ruQ3+Sf"}},"host":
{"port":20000,"ip":"13.66.168.246"},"serializer":2451810,"version":100}, 
{"system":{"shards":{"high":6917529027641081855,"low":4611686018427387904},"agent":
{"protocol":100,"name":"/Radix:/2270000","version":2270000},"period":152913929,"port":20000,"commitment":
{"serializer":"HASH","value":"0000000000000000000000000000000000000000000000000000000000000000"},"serializer":-1833998801,"clock":114,"version":100,"key":
```
Congratulations, you are now successfully running a Radix Node!

## Kitematic

This is optional, but if you are running your Node on a Mac or Windows computer you can download Kitematic to add a UI to your Docker container:
If you want access to nice buttons and a live log view; this is definitely for you!

[Kitematic by Docker](https://kitematic.com/)

## Node Configuration Options For docker-composer.yml

Changing the configuration below in your docker compose file requires that your re-run docker compose:

```shell
docker-compose -f basic-node.yml up -d
```

### WIPE_ADMIN_PASSWORD

Setting this to `yes` and restarting your `core` service will wipe your local ledger and re-sync it from other nodes in the RadixDLT network.

### WIPE_LEDGER

Setting this to `yes` and restarting your `core` service will wipe your local ledger and re-sync it from other nodes in the RadixDLT network.

### WIPE_NODE_KEY

Setting this to `yes` and restarting your `core` service will wipe your `node.key` file, which is your RadixDLT identity on the network. Hence, you will get a new identity and probably end up in a different shard.

### CORE_GOSSIP_PORT

This is `20000` for the Alpha network and needs to match the port encoded in the `CORE_UNIVERSE` string.

### CORE_NETWORK_SEEDS

Concrete IP address for discovering other nodes on the RadixDLT network.

Either `CORE_NETWORK_SEEDS` or `CORE_NETWORK_DISCOVERY_URLS` or both need to be set.

### CORE_NETWORK_DISCOVERY_URLS

The URL to a simple web service, which returns an IP address to a random node on
 the RadixDLT network. This IP address will be used for discovering other nodes on the network.

Either `CORE_NETWORK_DISCOVERY_URLS` or `CORE_NETWORK_SEEDS` or both need to be set.

### CORE_PARTITION_FRAGMENTS

Number of shards that the target network is partition in.
For the Alpha network is partitioned into `1` shards.

### CORE_UNIVERSE

Universe identity and properties (such as gossip port). This string separates two RadixDLT networks from each other.

# To Be Decided (TBD)

* Number of shards `CORE_PARTITION_FRAGMENTS`
* `radixdlt-core` docker image registr (`radixdlt.azurecr.io/radixdlt/radixdlt-core:latest-alpha`)
