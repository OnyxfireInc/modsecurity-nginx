#!/bin/bash

connectorVersion=1.0.0
nginxVersion=1.13.8
crsVersion=3.0.2

# Install dependencies
yum install yajl -y

# Create modules link if doesn't exist
if [ ! -d /etc/nginx/modules/ ]; then
	/usr/bin/ln -sf /usr/lib64/nginx/modules /etc/nginx/modules
fi

# Install or update modsecurity for nginx dynamic module
/usr/bin/wget -q -O /etc/nginx/modules/ngx_http_modsecurity_module.so https://onyxfireinc.com/open-source/modsecurity-nginx/${connectorVersion}/${nginxVersion}/ngx_http_modsecurity_module.so
chmod 0755 /etc/nginx/modules/ngx_http_modsecurity_module.so

# Create modsec directory if it doesn't exist
if [ ! -d /etc/nginx/modsec ]; then
	/usr/bin/mkdir /etc/nginx/modsec
	/usr/bin/chmod 0755 /etc/nginx/modsec
fi

# Install custom modsecurity config for nginx
/usr/bin/wget -q -O /etc/nginx/modsec/main.conf.new https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/main.conf
if [ ! -f /etc/nginx/modsec/main.conf ]; then
	/usr/bin/mv /etc/nginx/modsec/main.conf.new /etc/nginx/modsec/main.conf
fi

# Install nginx base configuration
/usr/bin/wget -q -O /etc/nginx/nginx.conf.new https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/nginx.conf
if [ ! -f /etc/nginx/nginx.conf ]; then
	/usr/bin/mv /etc/nginx/nginx.conf.new /etc/nginx/nginx.conf
fi

# Install default server config
/usr/bin/wget -q -O /etc/nginx/conf.d/default.conf.new https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/default.conf
if [ ! -f /etc/nginx/conf.d/default.conf ]; then
	/usr/bin/mv /etc/nginx/conf.d/default.conf.new /etc/nginx/conf.d/default.conf
fi

# Install logrotate configuration
/usr/bin/wget -q -O /etc/logrotate.d/nginx https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/nginx

# Install or update libmodsecurity
if [ -d /usr/local/modsecurity/ ]; then
	/usr/bin/rm -rf /usr/local/modsecurity/
fi
/usr/bin/wget -q -O - https://onyxfireinc.com/open-source/modsecurity/3.0.0/libmodsecurity.tar.gz | tar -zxm -C /usr/local

# Remove existing OWASP CRS rules
if [ -d /etc/nginx/modsec/crs ]; then
	/usr/bin/rm -rf /etc/nginx/modsec/crs/
fi

# Install OWASP CRS rules
/usr/bin/wget -q -O - https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v${crsVersion}.tar.gz | tar zx -C /etc/nginx/modsec/
/usr/bin/mv /etc/nginx/modsec/owasp-modsecurity-crs-${crsVersion} /etc/nginx/modsec/crs
/usr/bin/cp /etc/nginx/modsec/crs/crs-setup.conf.example /etc/nginx/modsec/crs/crs-setup.conf

# Install recommended modsecurity config
/usr/bin/wget -q -O /etc/nginx/modsec/modsecurity.conf-recommended https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended
if [ ! -f /etc/nginx/modsec/modsecurity.conf ]; then
	/usr/bin/mv /etc/nginx/modsec/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
	/usr/bin/sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf
fi
