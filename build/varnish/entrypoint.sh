#!/bin/bash

set -e


for i in BACKEND_PORT BACKEND_HOST
do
    eval value=\$$i
    sed -i "s|\${${i}}|${value}|g" /etc/varnish/default.vcl
done


exec bash -c "exec  varnishd -F -u varnish -P /var/run/varnish.pid -f /etc/varnish/default.vcl -a :6081 -T 127.0.0.1:6082 -t 120 -S /etc/varnish/secret -s malloc,$CACHE_SIZE"
