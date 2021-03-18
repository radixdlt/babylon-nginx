#!/bin/sh

set -e

[ "$NGINX_RESOLVER" ] || export NGINX_RESOLVER=$(awk '$1=="nameserver" {print $2;exit;}' </etc/resolv.conf)

if [[ "$RADIXDLT_ENABLE_FAUCET" == true ]];then
  export INCLUDE_RADIXDLT_FAUCET_ENABLED="include conf.d/faucet-conf.conf"
fi

export DOLLAR='$'
envsubst </etc/nginx/conf.d/nginx.conf.envsubst >/etc/nginx/nginx.conf

# Generate dhparam.pem if not pre-configured
if [ ! -f /etc/nginx/secrets/dhparam.pem ]; then
    # TODO: increase to 2048 for Beta
    openssl dhparam -out /etc/nginx/secrets/dhparam.pem  1024
fi

# Generate certificates if not pre-configured
if [ ! -f /etc/nginx/secrets/server.pem -o ! -f /etc/nginx/secrets/server.key ]; then
    # remove old links
    rm -f /etc/nginx/secrets/server.pem /etc/nginx/secrets/server.key
    openssl req  -nodes -new -x509 -nodes -subj '/CN=localhost' -keyout /etc/nginx/secrets/server.key -out /etc/nginx/secrets/server.pem
fi

generate_password() {
    local password=$3
    if [ -z "$password" ]; then
        password=$(openssl rand -base64 32)
        echo "==> Your new $2 password is: $password <=="
    fi
    printf "$2:%s" $(openssl passwd -apr1 "$password") > "$1"
}

# Generate htpasswd files if not pre-configured
[ -z "$ADMIN_PASSWORD" -a "$WIPE_ADMIN_PASSWORD" != yes ] || \
    rm -f /etc/nginx/secrets/htpasswd.admin
[ -z "$METRICS_PASSWORD" -a "$WIPE_METRICS_PASSWORD" != yes ] || \
    rm -f /etc/nginx/secrets/htpasswd.metrics
[ -f /etc/nginx/secrets/htpasswd.admin ] || \
    generate_password /etc/nginx/secrets/htpasswd.admin "${ADMIN_USER:-admin}" "${ADMIN_PASSWORD}"
[ -f /etc/nginx/secrets/htpasswd.metrics ] || \
    generate_password /etc/nginx/secrets/htpasswd.metrics "${METRICS_USER:-metrics}" "${METRICS_PASSWORD}"
unset ADMIN_USER ADMIN_PASSWORD METRICS_USER METRICS_PASSWORD

exec "$@"
