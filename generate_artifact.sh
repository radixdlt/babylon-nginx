#!/usr/bin/env bash


export RADIXDLT_VALIDATOR_HOST=127.0.0.1
export RADIXDLT_VALIDATOR_TCP_PORT=30001
export RADIXDLT_CORE_API_PORT=3333
export RADIXDLT_ENGINE_STATE_PORT=3336
export NGINX_VALIDATOR_TCP_PORT=30000
export NGINX_CLIENT_HTTP_PORT=8080
export NGINX_NODE_HTTP_PORT=3334
export RADIXDLT_ENGINE_STATE_ENABLE='true'

#Remove the nginx configuration part and generate nginx.conf
nginx_file_name="nginx-fullnode.conf"
sed '1,/# nginx configuration/!d' docker-entrypoint.sh  | sed 's/\/etc\/nginx/${PWD}/g' | bash
mv ${PWD}/nginx.conf ${PWD}/$nginx_file_name
#Remove nginx user
sed -i "s|user nginx;|include \/etc\/nginx\/modules-enabled\/*.conf;|g" ${PWD}/$nginx_file_name
#Change /dev/stdout and /dev/stderr
sed -i "s|\/dev\/stdout|\/var\/log\/nginx\/access.log|g" ${PWD}/$nginx_file_name
sed -i "s|\/dev\/stderr|\/var\/log\/nginx\/error.log|g" ${PWD}/$nginx_file_name
zip -r babylon-nginx-fullnode-conf.zip conf.d/ certs/ nginx-fullnode.conf
#Cleanup
rm nginx-fullnode.conf

