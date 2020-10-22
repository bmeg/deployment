
# redirect to https
server {
	listen *:80;
  server_name bmeg.io;
	return 301 https://$host$request_uri;
}

server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;

  server_name bmeg.io;
  ssl_certificate /etc/letsencrypt/live/bmeg.io/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/bmeg.io/privkey.pem;

  # content
  location / {
    root /usr/share/nginx/bmeg.io;
    try_files $uri $uri/index.html $uri.html =404;
  }
  # data
  location /data {
    alias /usr/share/nginx/bmeg.io.data/; # directory to list
    autoindex on;
  }
  # share
  location /share {
    alias /usr/share/nginx/bmeg.io.share/; # directory to list
    autoindex on;
  }
  # for certbot challenge
  location /.well-known/acme-challenge/ {
      root /var/www/certbot;
  }
  # for bmeg-dash
  location /app {
      proxy_pass http://bmeg-dash:8050;
  }

	##
  # oath setup
	# grip protected paths
	##
	include /etc/nginx/grip-bmeg.io.conf;

}
