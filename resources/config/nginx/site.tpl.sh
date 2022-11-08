#!/usr/bin/env bash

set -eu

cat << EOT
server {
EOT

if [[ -n "${ssl}" ]]; then
  cat << EOT
  listen 443 ssl http2;
  listen [::]:443 ssl http2;

  ssl_certificate /etc/letsencrypt/live/${name}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${name}/privkey.pem;
EOT
else
  cat << EOT
  listen 80;
  listen [::]:80;
EOT
fi

cat << EOT

  server_name ${name};
  root ${home_dir}/current/public;
  index index.html index.htm;
  charset utf8;

  access_log /var/log/nginx/access.${name#www.}.log combined;
  error_log /var/log/nginx/error.${name#www.}.log error;

  location ~ ^/(robots.txt|humans.txt|favicon.ico)\$ {
    access_log off;
    log_not_found off;
    try_files \$uri =404;
  }

  location ~ ^/(\.(?!well-known/)|wp[-/]) {
    access_log off;
    deny all;
  }

EOT

if [[ -n "${php}" ]]; then
  cat << EOT
  location / {
    try_files \$uri \$uri/ @app;
  }

  location @app {
    fastcgi_pass unix:/run/nginx/${name#www.}.sock;
    include fastcgi_params;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_NAME \$document_root/index.php;
    fastcgi_param SCRIPT_FILENAME \$document_root/index.php;
  }
EOT
elif [[ -n "${node}" ]]; then
  cat << EOT
  location / {
    try_files \$uri \$uri/ @app;
  }

  location @app {
    proxy_pass http://unix:/run/nginx/${name#www.}.sock:/;
    proxy_http_version 1.1;
    proxy_set_header Host \$host;
    proxy_set_header X-Forwarded-For \$remote_addr;
  }
EOT
fi

cat << EOT
}

EOT

if [[ -n "${aliases}" && -n "${ssl}" ]]; then
  cat << EOT
server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;

  ssl_certificate /etc/letsencrypt/live/${name}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${name}/privkey.pem;
  server_name ${aliases};

  location / {
    return 301 https://${name}\$request_uri;
  }
}

EOT
fi

if [[ -n "${aliases}" || -n "${ssl}" ]]; then
	cat << EOT
server {
  listen 80;
  listen [::]:80;

  server_name ${ssl:+$name }${aliases};

  location / {
    return 301 http${ssl:+s}://${name}\$request_uri;
  }
}

EOT
fi
