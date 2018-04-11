#!/bin/bash

cd ~

crsVersion=3.0.2

# Install dependencies
sudo /usr/bin/yum -q install wget yajl -y

# Install nginx repo if not installed currently
if [ ! -f /etc/yum.repos.d/nginx.repo ]; then
	/usr/bin/cat <<EOF > nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/\$basearch/
gpgcheck=0
enabled=1
EOF
	sudo /usr/bin/mv nginx.repo /etc/yum.repos.d/
	sudo /usr/bin/yum -qy install nginx
fi

# Get Nginx version
nginxVersion=v`nginx -v 2>&1 | awk -F '/' '{print $2}'`

# Create modules link if doesn't exist
if [ ! -d /etc/nginx/modules/ ]; then
	sudo /usr/bin/ln -sf /usr/lib64/nginx/modules /etc/nginx/modules
fi

# Create global configuration directory if it doesn't exist
if [ ! -d /etc/nginx/global.d ]; then
	sudo /usr/bin/mkdir /etc/nginx/global.d
	sudo /usr/bin/chmod 0755 /etc/nginx/global.d
fi

# Create template configuration directory if it doesn't exist
if [ ! -d /etc/nginx/template.d ]; then
	sudo /usr/bin/mkdir /etc/nginx/template.d
	sudo /usr/bin/chmod 0755 /etc/nginx/template.d
fi

# Install nginx base configuration
sudo /usr/bin/wget -q -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/nginx.conf

# Install default server config
if [ ! -f /etc/nginx/conf.d/default.conf ]; then
	sudo /usr/bin/wget -q -O /etc/nginx/conf.d/default.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/default.conf
fi

# Install global configuration
sudo /usr/bin/wget -q -O /etc/nginx/global.d/timeouts.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/timeouts.conf
sudo /usr/bin/wget -q -O /etc/nginx/global.d/cache-file-descriptors.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/cache-file-descriptors.conf
sudo /usr/bin/wget -q -O /etc/nginx/global.d/extra-security.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/extra-security.conf
sudo /usr/bin/wget -q -O /etc/nginx/global.d/gzip.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/gzip.conf
sudo /usr/bin/wget -q -O /etc/nginx/global.d/security.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/security.conf
sudo /usr/bin/wget -q -O /etc/nginx/global.d/proxy.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/proxy.conf

# Install configuration templates
sudo /usr/bin/wget -q -O /etc/nginx/template.d/ssl.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/ssl.conf
sudo /usr/bin/wget -q -O /etc/nginx/template.d/ssl-stapling.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/ssl-stapling.conf
sudo /usr/bin/wget -q -O /etc/nginx/template.d/robots.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/robots.conf
sudo /usr/bin/wget -q -O /etc/nginx/template.d/certbot.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/certbot.conf
sudo /usr/bin/wget -q -O /etc/nginx/template.d/php.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/php.conf
sudo /usr/bin/wget -q -O /etc/nginx/template.d/static-cache.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/static-cache.conf

# Install or update modsecurity for nginx dynamic module
sudo /usr/bin/wget -q -O /etc/nginx/modules/ngx_http_modsecurity_module.so https://github.com/OnyxFireInc/modsecurity-nginx/releases/download/${nginxVersion}/ngx_http_modsecurity_module.so
sudo /usr/bin/chmod 0755 /etc/nginx/modules/ngx_http_modsecurity_module.so

# Create modsec directory if it doesn't exist
if [ ! -d /etc/nginx/modsec ]; then
	sudo /usr/bin/mkdir /etc/nginx/modsec
	sudo /usr/bin/chmod 0755 /etc/nginx/modsec
fi

# Install custom modsecurity config for nginx
if [ ! -f /etc/nginx/modsec/main.conf ]; then
	sudo /usr/bin/wget -q -O /etc/nginx/modsec/main.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/main.conf
fi

# Install logrotate configuration
if [ -f /etc/logrotate.d/nginx ]; then
	sudo /usr/bin/rm -f /etc/logrotate.d/nginx
fi
sudo /usr/bin/wget -q -O /etc/logrotate.d/nginx https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/nginx

# Install or update libmodsecurity
if [ -d /usr/local/modsecurity/ ]; then
	sudo /usr/bin/rm -rf /usr/local/modsecurity/
fi
sudo /usr/bin/wget -q -O - https://github.com/OnyxFireInc/modsecurity-nginx/releases/download/${nginxVersion}/libmodsecurity.tar.gz | sudo /usr/bin/tar -zxm -C /usr/local

# Remove existing OWASP CRS rules
if [ -d /etc/nginx/modsec/crs ]; then
	sudo /usr/bin/rm -rf /etc/nginx/modsec/crs/
fi

# Install OWASP CRS rules
sudo /usr/bin/wget -q -O - https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v${crsVersion}.tar.gz | sudo /usr/bin/tar zx -C /etc/nginx/modsec/
sudo /usr/bin/mv /etc/nginx/modsec/owasp-modsecurity-crs-${crsVersion} /etc/nginx/modsec/crs
sudo /usr/bin/cp /etc/nginx/modsec/crs/crs-setup.conf.example /etc/nginx/modsec/crs/crs-setup.conf

# Install modsecurity config
sudo /usr/bin/wget -q -O /etc/nginx/modsec/modsecurity.conf https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended
sudo /usr/bin/sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf
sudo /usr/bin/sed -i 's/SecAuditLog \/var\/log\/modsec_audit\.log/SecAuditLog \/var\/log\/nginx\/modsec_audit\.log/' /etc/nginx/modsec/modsecurity.conf

# Configure SELinux
sudo /usr/sbin/setsebool -P httpd_setrlimit 1
sudo /usr/sbin/setsebool -P httpd_execmem 1
sudo /usr/bin/touch /.autorelabel

# Exit message
/usr/bin/echo Reboot server now to complete setup...
