#!/bin/sh

set -e

# API is the last to come up when starting
exec wget -qO- http://$HOSTNAME:8080/api/universe >/dev/null
