server {
	listen 80;

	server_name bmeg.io;

	location / {
		root /usr/share/nginx/default;
		try_files $uri $uri/index.html $uri.html =404;
	}
}
