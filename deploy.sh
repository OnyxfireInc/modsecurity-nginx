#!/bin/bash

modsecurityBranch=v3/master
crsVersion=3.0.2

# Create modules link if doesn't exist
if [ ! -d /etc/nginx/modules/ ]; then
	ln -sf /usr/lib64/nginx/modules /etc/nginx/modules
fi

# Install modsecurity for nginx dynamic module
cp -f ./ngx_http_modsecurity_module.so /etc/nginx/modules/

# Create modsec directory if it doesn't exist
if [ ! -d /etc/nginx/modsec ]; then
	mkdir /etc/nginx/modsec
	cp ./main.conf /etc/nginx/modsec/
fi

# Install custom modsecurity config for nginx
if [ ! -f /etc/nginx/modsec/main.conf ]; then
	cp ./main.conf /etc/nginx/modsec/
else
	cp ./main.conf /etc/nginx/modsec/main.conf.new
fi

# Install default config
if [ ! -f /etc/nginx/conf.d/default.conf ]; then
	cp ./default.conf /etc/nginx/conf.d/
else
	cp ./default.conf /etc/nginx/conf.d/default.conf.new
fi

# Install libmodsecurity
if [ ! -d /usr/local/modsecurity/ ]; then
	tar -zxvf ./modsecurity.tar.gz -C /usr/local/modsecurity/
	find /usr/local/modsecurity/ -type d -exec chmod 0755 {} \;
	find /usr/local/modsecurity/ -type f -exec chmod 0644 {} \;
	chmod 0755 /usr/local/modsecurity/lib/libmodsecurity.la /usr/local/modsecurity/lib/libmodsecurity.so.3.0.0
	ln -sf /usr/local/modsecurity/lib/libmodsecurity.so.3.0.0 /usr/local/modsecurity/lib/libmodsecurity.so
	ln -sf /usr/local/modsecurity/lib/libmodsecurity.so.3.0.0 /usr/local/modsecurity/lib/libmodsecurity.so.3
fi

# Remove existing OWASP CRS rules
if [ -d /etc/nginx/modsec/crs ]; then
	rm -rf /etc/nginx/modsec/crs/
fi

# Install OWASP CRS rules
wget https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v${crsVersion}.tar.gz
tar -zxf v${crsVersion}.tar.gz -C /etc/nginx/modsec/
mv /etc/nginx/modsec/owasp-modsecurity-crs-${crsVersion} /etc/nginx/modsec/crs

# Install recommended modsecurity config
wget -P /etc/nginx/modsec/ https://raw.githubusercontent.com/SpiderLabs/ModSecurity/${modsecurityBranch}/modsecurity.conf-recommended
if [ ! -f /etc/nginx/modsec/modsecurity.conf ]; then
	mv /etc/nginx/modsec/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
	sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf
fi
