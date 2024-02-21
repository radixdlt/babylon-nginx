#!/bin/sh

set -e

generate_cloudflare_ip_conf(){
  ip4s="$(wget -qO- https://www.cloudflare.com/ips-v4 2>/dev/null)"
  ip6s="$(wget -qO- https://www.cloudflare.com/ips-v6 2>/dev/null)"
  echo "" > /etc/nginx/conf.d/set-real-ip-cloudflare.conf
  for ip in $ip4s; do
    echo "set_real_ip_from ${ip};" >> /etc/nginx/conf.d/set-real-ip-cloudflare.conf
  done

  for ip in $ip6s; do
    echo "set_real_ip_from ${ip};" >> /etc/nginx/conf.d/set-real-ip-cloudflare.conf
  done
  echo "real_ip_header    CF-Connecting-IP;" >> /etc/nginx/conf.d/set-real-ip-cloudflare.conf
}

set_default_rate_limits(){
  [ "$RADIXDLT_ENABLE_DEFAULT_RATE_LIMITS" ] || export RADIXDLT_ENABLE_DEFAULT_RATE_LIMITS="true"
  if [[ "$RADIXDLT_ENABLE_DEFAULT_RATE_LIMITS" == true || "$RADIXDLT_ENABLE_DEFAULT_RATE_LIMITS" == "True" ]];then
    export INCLUDE_DEFAULT_RATE_LIMITS="      limit_req zone=perip burst=500 nodelay;
    limit_req zone=perserver burst=500 nodelay;"
  fi
}

enable_or_disable_basic_auth_for_gateway_api(){
  [ "$RADIXDLT_GATEWAY_BEHIND_AUTH" ] || export RADIXDLT_GATEWAY_BEHIND_AUTH=true
  if [[ "$RADIXDLT_GATEWAY_BEHIND_AUTH" == true || "$RADIXDLT_GATEWAY_BEHIND_AUTH" == "True" ]];then
    export ENABLE_GATEWAY_BEHIND_AUTH="auth_basic_user_file /etc/nginx/secrets/htpasswd.gateway;
    auth_basic on;"
  else
    export ENABLE_GATEWAY_BEHIND_AUTH="auth_basic off;"
  fi
}

set_default_rate_limits

[ "$NGINX_RESOLVER" ] || export NGINX_RESOLVER=$(awk '$1=="nameserver" {print $2;exit;}' </etc/resolv.conf)

[ "$RADIXDLT_VALIDATOR_HOST" ] || export RADIXDLT_VALIDATOR_HOST=core
[ "$RADIXDLT_GATEWAY_API_HOST" ] || export RADIXDLT_GATEWAY_API_HOST=gateway_api
[ "$RADIXDLT_GATEWAY_API_PORT" ] || export RADIXDLT_GATEWAY_API_PORT=80
[ "$RADIXDLT_GATEWAY_METRICS_PORT" ] || export RADIXDLT_GATEWAY_METRICS_PORT=1235
[ "$RADIXDLT_DATA_AGGREGATOR_HOST" ] || export RADIXDLT_DATA_AGGREGATOR_HOST=data_aggregator
[ "$RADIXDLT_DATA_AGGREGATOR_METRICS_PORT" ] || export RADIXDLT_DATA_AGGREGATOR_METRICS_PORT=1234
[ "$RADIXDLT_VALIDATOR_TCP_PORT" ] || export RADIXDLT_VALIDATOR_TCP_PORT=30000
[ "$RADIXDLT_CORE_API_PORT" ] || export RADIXDLT_CORE_API_PORT=3333
[ "$RADIXDLT_SYSTEM_API_PORT" ] || export RADIXDLT_SYSTEM_API_PORT=3334
[ "$RADIXDLT_PROMETHEUS_API_PORT" ] || export RADIXDLT_PROMETHEUS_API_PORT=3335
[ "$NGINX_VALIDATOR_TCP_PORT" ] || export NGINX_VALIDATOR_TCP_PORT=30000
[ "$NGINX_CLIENT_HTTP_PORT" ] || export NGINX_CLIENT_HTTP_PORT=8080


[ "$NGINX_LOGS_DIR" ] || export NGINX_LOGS_DIR="/var/log/nginx"
[ "$NGINX_BEHIND_CLOUDFLARE" ] || export NGINX_BEHIND_CLOUDFLARE=false
if [[ "$NGINX_BEHIND_CLOUDFLARE" == true || "$NGINX_BEHIND_CLOUDFLARE" == "True" ]];then
  generate_cloudflare_ip_conf
  export INCLUDE_NGINX_BEHIND_CLOUDFLARE="include conf.d/set-real-ip-cloudflare.conf;"
fi


[ "$RADIXDLT_NETWORK_USE_PROXY_PROTOCOL" ] || export RADIXDLT_NETWORK_USE_PROXY_PROTOCOL=false
if [[ "$RADIXDLT_NETWORK_USE_PROXY_PROTOCOL" == true || "$RADIXDLT_NETWORK_USE_PROXY_PROTOCOL" == "True" ]];then
  export INCLUDE_RADIXDLT_NETWORK_USE_PROXY_PROTOCOL="proxy_protocol on;"
fi

[ "$RADIXDLT_TRANSACTIONS_API_ENABLE" ] || export RADIXDLT_TRANSACTIONS_API_ENABLE=false
if [[ "$RADIXDLT_TRANSACTIONS_API_ENABLE" == true || "$RADIXDLT_TRANSACTIONS_API_ENABLE" == "True" ]];then
  transactions_conf_file="transactions"
  export INCLUDE_RADIXDLT_TRANSACTIONS_API_ENABLE="include conf.d/${transactions_conf_file}.conf;"
  DOLLAR='$' envsubst </etc/nginx/conf.d/${transactions_conf_file}.conf.envsubst >/etc/nginx/conf.d/${transactions_conf_file}.conf
fi


[ "$RADIXDLT_GATEWAY_API_ENABLE" ] || export RADIXDLT_GATEWAY_API_ENABLE=false
if [[ "$RADIXDLT_GATEWAY_API_ENABLE" == true || "$RADIXDLT_GATEWAY_API_ENABLE" == "True" ]];then
  gatewayapi_conf_file="gatewayapi"
  export INCLUDE_RADIXDLT_GATEWAY_API_ENABLE="include conf.d/${gatewayapi_conf_file}.conf;"
  enable_or_disable_basic_auth_for_gateway_api
  DOLLAR='$' envsubst </etc/nginx/conf.d/${gatewayapi_conf_file}.conf.envsubst >/etc/nginx/conf.d/${gatewayapi_conf_file}.conf
fi


[ "$RADIXDLT_ENABLE_TCP_CORE_PROXY" ] || export RADIXDLT_ENABLE_TCP_CORE_PROXY=true
if [[ "$RADIXDLT_ENABLE_TCP_CORE_PROXY" == true || "$RADIXDLT_ENABLE_TCP_CORE_PROXY" == "True" ]];then
  tcp_server_conf="coretcpserver"
  export INCLUDE_RADIXDLT_ENABLE_TCP_CORE_PROXY="include conf.d/${tcp_server_conf}.conf;"
  DOLLAR='$' envsubst </etc/nginx/conf.d/${tcp_server_conf}.conf.envsubst >/etc/nginx/conf.d/${tcp_server_conf}.conf
fi

coreapi_conf_file="coreapi"
export INCLUDE_RADIXDLT_CORE_API_ENABLE="include conf.d/${coreapi_conf_file}.conf;"
DOLLAR='$' envsubst </etc/nginx/conf.d/${coreapi_conf_file}.conf.envsubst >/etc/nginx/conf.d/${coreapi_conf_file}.conf

system_conf_file="system"
export INCLUDE_RADIXDLT_SYSTEM_API_ENABLE="include conf.d/${system_conf_file}.conf;"
DOLLAR='$' envsubst </etc/nginx/conf.d//${system_conf_file}.conf.envsubst >/etc/nginx/conf.d//${system_conf_file}.conf

conf_file="metrics"
export INCLUDE_RADIXDLT_METRICS_API_ENABLE="include conf.d/${conf_file}.conf;"
DOLLAR='$' envsubst </etc/nginx/conf.d/${conf_file}.conf.envsubst >/etc/nginx/conf.d/${conf_file}.conf

DOLLAR='$' envsubst </etc/nginx/conf.d/nginx.conf.envsubst >/etc/nginx/nginx.conf

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
[ -z "$SUPER_ADMIN_PASSWORD" -a "$SUPER_ADMIN_PASSWORD" != yes ] || \
    rm -f /etc/nginx/secrets/htpasswd.admin
[ -z "$GATEWAY_PASSWORD" -a "$GATEWAY_PASSWORD" != yes ] || \
    rm -f /etc/nginx/secrets/htpasswd.gateway

[ -f /etc/nginx/secrets/htpasswd.admin ] || \
    generate_password /etc/nginx/secrets/htpasswd.admin "${ADMIN_USER:-admin}" "${ADMIN_PASSWORD}"
[ -f /etc/nginx/secrets/htpasswd.metrics ] || \
    generate_password /etc/nginx/secrets/htpasswd.metrics "${METRICS_USER:-metrics}" "${METRICS_PASSWORD}"
[ -f /etc/nginx/secrets/htpasswd.metrics ] || \
    generate_password /etc/nginx/secrets/htpasswd.superadmin "${SUPER_ADMIN_USER:-superadmin}" "${SUPER_ADMIN_PASSWORD}"
[ -f /etc/nginx/secrets/htpasswd.gateway ] || \
    generate_password /etc/nginx/secrets/htpasswd.gateway "${GATEWAY_USER:-gateway}" "${GATEWAY_PASSWORD}"
unset ADMIN_USER ADMIN_PASSWORD METRICS_USER METRICS_PASSWORD SUPER_ADMIN_USER SUPER_ADMIN_PASSWORD GATEWAY_USER GATEWAY_PASSWORD

exec "$@"
