#!/bin/sh

set -e

exec wget -qO- --no-check-certificate  https://$HOSTNAME/nginx-status >/dev/null
