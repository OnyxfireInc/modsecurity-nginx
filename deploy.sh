#!/bin/bash

/usr/bin/cd ~

version=v1.13.11
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
	sudo /usr/bin/yum -q install nginx
fi

# Create modules link if doesn't exist
if [ ! -d /etc/nginx/modules/ ]; then
	sudo /usr/bin/ln -sf /usr/lib64/nginx/modules /etc/nginx/modules
fi

# Install or update modsecurity for nginx dynamic module
sudo /usr/bin/wget -q -O /etc/nginx/modules/ngx_http_modsecurity_module.so https://github.com/OnyxFireInc/modsecurity-nginx/releases/download/${version}/ngx_http_modsecurity_module.so
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

# Install nginx base configuration
if [ ! -f /etc/nginx/nginx.conf ]; then
	sudo /usr/bin/wget -q -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/nginx.conf
	sudo /usr/bin/wget -q -O /etc/nginx/ssl.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/ssl.conf
	sudo /usr/bin/wget -q -O /etc/nginx/ssl-stapling.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/ssl-stapling.conf
	sudo /usr/bin/wget -q -O /etc/nginx/cache-file-descriptors.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/cache-file-descriptors.conf
	sudo /usr/bin/wget -q -O /etc/nginx/extra-security.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/extra-security.conf
	sudo /usr/bin/wget -q -O /etc/nginx/gzip.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/gzip.conf
	sudo /usr/bin/wget -q -O /etc/nginx/proxy.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/proxy.conf
	sudo /usr/bin/wget -q -O /etc/nginx/security.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/security.conf
fi

# Install default server config
if [ ! -f /etc/nginx/conf.d/default.conf ]; then
	sudo /usr/bin/wget -q -O /etc/nginx/conf.d/default.conf https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/default.conf
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
sudo /usr/bin/wget -q -O - https://github.com/OnyxFireInc/modsecurity-nginx/releases/download/${version}/libmodsecurity.tar.gz | sudo /usr/bin/tar -zxm -C /usr/local

# Remove existing OWASP CRS rules
if [ -d /etc/nginx/modsec/crs ]; then
	sudo /usr/bin/rm -rf /etc/nginx/modsec/crs/
fi

# Install OWASP CRS rules
sudo /usr/bin/wget -q -O - https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v${crsVersion}.tar.gz | sudo /usr/bin/tar zx -C /etc/nginx/modsec/
sudo /usr/bin/mv /etc/nginx/modsec/owasp-modsecurity-crs-${crsVersion} /etc/nginx/modsec/crs
sudo /usr/bin/cp /etc/nginx/modsec/crs/crs-setup.conf.example /etc/nginx/modsec/crs/crs-setup.conf

# Install modsecurity config
if [ ! -f /etc/nginx/modsec/modsecurity.conf ]; then
	sudo /usr/bin/wget -q -O /etc/nginx/modsec/modsecurity.conf https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended
	sudo /usr/bin/sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf
	sudo /usr/bin/sed -i 's/SecAuditLog \/var\/log\/modsec_audit.log/SecAuditLog \/var\/log\/nginx\/modsec_audit.log/' /etc/nginx/modsec/modsecurity.conf
fi

# Configure SELinux
sudo /usr/sbin/setsebool -P httpd_setrlimit 1
sudo /usr/sbin/setsebool -P httpd_execmem 1
sudo /usr/bin/touch /.autorelabel

# Exit message
/usr/bin/echo
/usr/bin/echo Reboot server now to complete setup...
