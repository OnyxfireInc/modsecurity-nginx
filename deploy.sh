#!/bin/bash

cd ~

crsVersion=3.0.2

# Install dependencies
sudo /usr/bin/yum -q install yajl -y

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
	sudo /usr/bin/yum -q install nginx -y
fi

# Get Nginx version
if [ ! -z $1 ]; then
	nginxVersion=$1
else
	nginxVersion=v`nginx -v 2>&1 | awk -F '/' '{print $2}'`
fi

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
sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/nginx.conf >/etc/nginx/nginx.conf"

# Install default server config
if [ ! -f /etc/nginx/conf.d/default.conf ]; then
	sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/default.conf >/etc/nginx/conf.d/default.conf"
fi

# Install global configuration
sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/timeouts.conf >/etc/nginx/global.d/timeouts.conf"
sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/cache-file-descriptors.conf >/etc/nginx/global.d/cache-file-descriptors.conf"
sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/extra-security.conf >/etc/nginx/global.d/extra-security.conf"
sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/gzip.conf >/etc/nginx/global.d/gzip.conf"
sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/security.conf >/etc/nginx/global.d/security.conf"
sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/proxy.conf >/etc/nginx/global.d/proxy.conf"

# Install configuration templates
sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/ssl.conf >/etc/nginx/template.d/ssl.conf"
sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/ssl-stapling.conf >/etc/nginx/template.d/ssl-stapling.conf"
sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/robots.conf >/etc/nginx/template.d/robots.conf"
sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/certbot.conf >/etc/nginx/template.d/certbot.conf"
sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/php.conf >/etc/nginx/template.d/php.conf"
sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/static-cache.conf >/etc/nginx/template.d/static-cache.conf"

# Install or update modsecurity for nginx dynamic module
sudo -E sh -c "/usr/bin/curl -s https://github.com/OnyxFireInc/modsecurity-nginx/releases/download/${nginxVersion}/ngx_http_modsecurity_module.so >/etc/nginx/modules/ngx_http_modsecurity_module.so"
sudo /usr/bin/chmod 0755 /etc/nginx/modules/ngx_http_modsecurity_module.so

# Create modsec directory if it doesn't exist
if [ ! -d /etc/nginx/modsec ]; then
	sudo /usr/bin/mkdir /etc/nginx/modsec
	sudo /usr/bin/chmod 0755 /etc/nginx/modsec
fi

# Install custom modsecurity config for nginx
if [ ! -f /etc/nginx/modsec/main.conf ]; then
	sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/main.conf >/etc/nginx/modsec/main.conf"
fi

# Install logrotate configuration
sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/nginx >/etc/logrotate.d/nginx"

# Install or update libmodsecurity
if [ -d /usr/local/modsecurity/ ]; then
	sudo /usr/bin/rm -rf /usr/local/modsecurity/
fi
/usr/bin/curl -Ls https://github.com/OnyxFireInc/modsecurity-nginx/releases/download/${nginxVersion}/libmodsecurity.tar.gz | sudo /usr/bin/tar -zxm -C /usr/local

# Remove existing OWASP CRS rules
if [ -d /etc/nginx/modsec/crs ]; then
	sudo /usr/bin/rm -rf /etc/nginx/modsec/crs/
fi

# Install OWASP CRS rules
/usr/bin/curl -Ls https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v${crsVersion}.tar.gz | sudo /usr/bin/tar zx -C /etc/nginx/modsec/
sudo /usr/bin/mv /etc/nginx/modsec/owasp-modsecurity-crs-${crsVersion} /etc/nginx/modsec/crs
sudo /usr/bin/cp /etc/nginx/modsec/crs/crs-setup.conf.example /etc/nginx/modsec/crs/crs-setup.conf

# Install modsecurity config
sudo -E sh -c "/usr/bin/curl -s https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended >/etc/nginx/modsec/modsecurity.conf"
sudo /usr/bin/sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf
sudo /usr/bin/sed -i 's/SecAuditLog \/var\/log\/modsec_audit\.log/SecAuditLog \/var\/log\/nginx\/modsec_audit\.log/' /etc/nginx/modsec/modsecurity.conf

# Configure SELinux
sudo /usr/sbin/setsebool -P httpd_setrlimit 1
sudo /usr/sbin/setsebool -P httpd_execmem 1

# Exit message
/usr/bin/echo Reboot server now to complete setup...
