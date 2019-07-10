server {
  listen 80;
  # listen 443 ssl http2;
  # listen [::]:443 ssl http2;
  # ssl_protocols TLSv1.2 TLSv1.1 TLSv1;

  server_name bmegio.io;
  # ssl_certificate /etc/ssl/certs/bmegio.io.crt;
  # ssl_certificate_key /etc/ssl/private/bmegio.io.key;

  location / {
    root /usr/share/nginx/test-html;
    try_files $uri $uri/index.html $uri.html =404;
  }
}
