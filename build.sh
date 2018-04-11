#!/bin/bash

cd ~

modsecurityVersion=3.0.2
connectorVersion=1.0.0

# Install dependencies
sudo /usr/bin/yum -q install wget gcc-c++ flex bison yajl yajl-devel curl-devel GeoIP-devel doxygen zlib-devel \
    pcre-devel libxml2-devel openssl-devel -y

# Install mainline nginx repo if not installed currently
if [ ! -f /etc/yum.repos.d/nginx.repo ]; then
    /usr/bin/cat <<EOF > nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/\$basearch/
gpgcheck=0
enabled=1
EOF
    sudo /usr/bin/mv nginx.repo /etc/yum.repos.d/
fi

# Install Nginx
sudo /usr/bin/yum -q install nginx

# Get Nginx version
nginxVersion=`nginx -v 2>&1 | awk -F '/' '{print $2}'`

# Download source code
/usr/bin/wget -q -O - https://github.com/SpiderLabs/ModSecurity/releases/download/v${modsecurityVersion}/modsecurity-v${modsecurityVersion}.tar.gz | /usr/bin/tar -xz -C ~
/usr/bin/wget -q -O - https://github.com/SpiderLabs/ModSecurity-nginx/releases/download/v${connectorVersion}/modsecurity-nginx-v${connectorVersion}.tar.gz | /usr/bin/tar -xz -C ~
/usr/bin/wget -q -O - http://nginx.org/download/nginx-${nginxVersion}.tar.gz | /usr/bin/tar -xz -C ~

# Build and install libmodsecurity
cd modsecurity-v${modsecurityVersion}
./configure
/usr/bin/make
sudo /usr/bin/make install
cd ~

# Build and install nginx dynamic module
cd nginx-${nginxVersion}
options=`2>&1 nginx -V | grep configure | cut -c 22-`
options="$options --add-dynamic-module=../modsecurity-nginx-v${connectorVersion}"
/usr/bin/echo $options | xargs ./configure
/usr/bin/make modules
sudo /usr/bin/cp objs/ngx_http_modsecurity_module.so /etc/nginx/modules
cd ~

# Package files for distribution
/usr/bin/tar -zcf libmodsecurity.tar.gz -C /usr/local modsecurity/
/usr/bin/cp /etc/nginx/modules/ngx_http_modsecurity_module.so .

# Cleanup source code
/usr/bin/rm -rf modsecurity-v${modsecurityVersion}
/usr/bin/rm -rf nginx-${nginxVersion}
/usr/bin/rm -rf modsecurity-nginx-v${connectorVersion}
