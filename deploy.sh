#!/bin/bash

nginxVersion=v1.13.8
crsVersion=3.0.2

# Create modules link if doesn't exist
if [ ! -d /etc/nginx/modules/ ]; then
	ln -sf /usr/lib64/nginx/modules /etc/nginx/modules
fi

# Install modsecurity for nginx dynamic module
wget -q -P /etc/nginx/modules/ https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/${nginxVersion}/ngx_http_modsecurity_module.so

# Create modsec directory if it doesn't exist
if [ ! -d /etc/nginx/modsec ]; then
	mkdir /etc/nginx/modsec
fi

# Install custom modsecurity config for nginx
wget -q -O /etc/nginx/modsec/main.conf.new https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/main.conf

# Install nginx base configuration
wget -q -O /etc/nginx/nginx.conf.new https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/nginx.conf

# Install default server config
wget -q -O /etc/nginx/conf.d/default.conf.new https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/default.conf

# Install or update installed libmodsecurity
if [ -d /usr/local/modsecurity/ ]; then
	rm -rf /usr/local/modsecurity/
fi
wget -q -O - https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/modsecurity.tar.gz | tar -zx -C /usr/local
find /usr/local/modsecurity/ -type d -exec chmod 0755 {} \;
find /usr/local/modsecurity/ -type f -exec chmod 0644 {} \;
chmod 0755 /usr/local/modsecurity /usr/local/modsecurity/lib/libmodsecurity.la /usr/local/modsecurity/lib/libmodsecurity.so.3.0.0
ln -sf /usr/local/modsecurity/lib/libmodsecurity.so.3.0.0 /usr/local/modsecurity/lib/libmodsecurity.so
ln -sf /usr/local/modsecurity/lib/libmodsecurity.so.3.0.0 /usr/local/modsecurity/lib/libmodsecurity.so.3

# Remove existing OWASP CRS rules
if [ -d /etc/nginx/modsec/crs ]; then
	rm -rf /etc/nginx/modsec/crs/
fi

# Install OWASP CRS rules
wget -q -O - https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v${crsVersion}.tar.gz | tar zx -C /etc/nginx/modsec/
mv /etc/nginx/modsec/owasp-modsecurity-crs-${crsVersion} /etc/nginx/modsec/crs
cp /etc/nginx/modsec/crs/crs-setup.conf.example /etc/nginx/modsec/crs/crs/crs-setup.conf

# Install recommended modsecurity config
wget -q -P /etc/nginx/modsec/ https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended
if [ ! -f /etc/nginx/modsec/modsecurity.conf ]; then
	mv /etc/nginx/modsec/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
	sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf
fi
