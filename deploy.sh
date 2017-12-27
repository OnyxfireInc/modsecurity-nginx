#!/bin/bash

if [ ! -d /etc/nginx/modules/ ]; then
	ln -sf /usr/lib64/nginx/modules /etc/nginx/modules
fi

cp -f ./ngx_http_modsecurity_module.so /etc/nginx/modules/

if [ ! -d /etc/nginx/modsec ]; then
	mkdir /etc/nginx/modsec
	cp ./main.conf /etc/nginx/modsec/
fi

if [ ! -f /etc/nginx/modsec/main.conf ]; then
	cp ./main.conf /etc/nginx/modsec/
else
	cp ./main.conf /etc/nginx/modsec/main.conf.new
fi

if [ ! -f /etc/nginx/conf.d/default.conf ]; then
	cp ./default.conf /etc/nginx/conf.d/
else
	cp ./default.conf /etc/nginx/conf.d/default.conf.new
fi

if [ ! -d /usr/local/modsecurity/ ]; then
	tar -zxvf ./modsecurity.tar.gz -C /usr/local/modsecurity/
	find /usr/local/modsecurity/ -type d -exec chmod 0755 {} \;
	find /usr/local/modsecurity/ -type f -exec chmod 0644 {} \;
	chmod 0755 /usr/local/modsecurity/lib/libmodsecurity.la /usr/local/modsecurity/lib/libmodsecurity.so.3.0.0
	ln -sf /usr/local/modsecurity/lib/libmodsecurity.so.3.0.0 /usr/local/modsecurity/lib/libmodsecurity.so
	n -sf /usr/local/modsecurity/lib/libmodsecurity.so.3.0.0 /usr/local/modsecurity/lib/libmodsecurity.so.3
fi
