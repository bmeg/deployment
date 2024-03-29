##
# websocket config
##
# top-level http config for websocket headers
# If Upgrade is defined, Connection = upgrade
# If Upgrade is empty, Connection = close
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}



# --------- main gen3 server
server {
	listen *:80;
  server_name commons.bmeg.io;
	return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name commons.bmeg.io;

    ssl_certificate /etc/letsencrypt/live/commons.bmeg.io/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/commons.bmeg.io/privkey.pem;


    set $access_token "";
    set $csrf_check "ok-tokenauth";
    if ($cookie_access_token) {
            set $access_token "bearer $cookie_access_token";
            # cookie auth requires csrf check
            set $csrf_check "fail";
    }
    if ($http_authorization) {
            # Authorization header is present - prefer that token over cookie token
            set $access_token "$http_authorization";
    }

    proxy_set_header   Authorization "$access_token";
    # proxy_set_header   X-Forwarded-For "$realip";
    # proxy_set_header   X-UserId "$userid";

    #
    # Accomodate large jwt token headers
    # * http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_buffer_size
    # * https://ma.ttias.be/nginx-proxy-upstream-sent-big-header-reading-response-header-upstream/
    #
    proxy_buffer_size          16k;
    proxy_buffers              8 16k;
    proxy_busy_buffers_size    32k;
    #
    # also incoming from client:
    # * https://fullvalence.com/2016/07/05/cookie-size-in-nginx/
    # * https://nginx.org/en/docs/http/ngx_http_core_module.html#client_header_buffer_size
    large_client_header_buffers 4 8k;
    client_header_buffer_size 4k;

    #
    # CSRF check
    # This block requires a csrftoken for all POST requests.
    #
    if ($cookie_csrftoken = $http_x_csrf_token) {
      # this will fail further below if cookie_csrftoken is empty
      set $csrf_check "ok-$cookie_csrftoken";
    }
    if ($request_method != "POST") {
      set $csrf_check "ok-$request_method";
    }
    if ($cookie_access_token = "") {
      # do this again here b/c empty cookie_csrftoken == empty http_x_csrf_token - ugh
      set $csrf_check "ok-tokenauth";
    }

    location / {
            proxy_pass http://portal-service/;
    }

    location /user/ {
            proxy_pass http://fence-service/;
    }

    location /api/ {
            proxy_pass http://sheepdog-service/;
    }

    location /coremetadata/ {
        # redirect to coremetadata landing page if header does not specify otherwise
        if ($http_accept !~ (application/json|x-bibtex|application/vnd\.schemaorg\.ld\+json)) {
          rewrite ^/coremetadata/(.*) /files/$1 redirect;
        }

        rewrite ^/coremetadata/(.*) /$1 break;
        proxy_pass http://pidgin-service;
    }

    location /index/ {
            proxy_pass http://indexd-service/;
    }
    location /peregrine/_status {
        proxy_pass http://peregrine-service/_status;
    }
    location /pidgin/_status {
        proxy_pass http://pidgin-service/_status;
    }

    location /api/v0/submission/getschema {
        proxy_pass http://peregrine-service/v0/submission/getschema;
    }

    location /guppy/ {
            proxy_pass http://guppy-service:3000/;
    }

    location /api/v0/submission/graphql {
            if ($cookie_csrftoken = "") {
                    add_header Set-Cookie "csrftoken=$request_length$request_time$time_iso8601;Path=/";  # $request_id
            }
            proxy_next_upstream off;
            # Forward the host and set Subdir header so api
            # knows the original request path for hmac signing
            proxy_set_header   Host $host;
            proxy_set_header   Subdir /api;
            proxy_set_header   Authorization "$access_token";
            proxy_connect_timeout 300;
            proxy_send_timeout 300;
            proxy_read_timeout 300;
            send_timeout 300;
            proxy_pass http://peregrine-service/v0/submission/graphql;
    }

    location /api/search {
        if ($csrf_check !~ ^ok-\S.+$) {
          return 403 "failed csrf check";
        }

        gzip off;
        proxy_next_upstream off;
        proxy_set_header   Host $host;
        proxy_set_header   Authorization "$access_token";

        proxy_connect_timeout 300;
        proxy_send_timeout 300;
        proxy_read_timeout 300;
        send_timeout 300;

        rewrite ^/api/search/(.*) /$1 break;
        proxy_pass http://peregrine-service;
    }

    location @errorworkspace {
        return 302 https://$host/no-workspace-access;
    }

    #
    # workspace AuthZ-proxy uses arborist to provide authorization to workpace services
    # that don't implement our authn or authz i.e. shiny, jupyter.
    #
    location = /gen3-authz {
        internal;
        error_page 400 =403 @errorworkspace;
        error_page 500 =403 @errorworkspace;

        proxy_pass http://fence-service/user/anyaccess;
        proxy_pass_request_body off;
        proxy_set_header Authorization "$access_token";
        proxy_set_header Content-Length "";
        proxy_intercept_errors on;
        # nginx bug that it checks even if request_body off
        client_max_body_size 0;
    }


    location = /authz/mapping {
        if ($csrf_check !~ ^ok-\S.+$) {
            return 403 "failed csrf check";
        }

        # Do not expose POST /auth/mapping
        limit_except GET {
            deny all;
        }

        # Do not pass the username arg here! Otherwise anyone can see anyone's access.
        # Arborist will fall back to parsing the jwt for username.
        proxy_pass http://arborist-service/auth/mapping;
    }

    error_page 401 = @error401;

    # If the user is not logged in, redirect them to Vouch's login URL
    location @error401 {
      return 302 https://$host/login;
    }


    ##
    # for elastic
    ##
    location /elastic/ {
      auth_request /vouch-auth;
      auth_request_set $authorization $upstream_http_authorization;
      # voucher returns a simplified jwt token
      proxy_pass http://esproxy-service:9200/;
      proxy_set_header Authorization $authorization;
      proxy_pass_header  Authorization;
    }

    location /kibana {
      auth_request /vouch-auth;
      auth_request_set $authorization $upstream_http_authorization;
      rewrite /kibana/(.*) /$1 break;
      proxy_pass http://kibana-service:5601/;
      # voucher returns a simplified jwt token
      proxy_set_header Authorization $authorization;
      proxy_pass_header  Authorization;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection 'upgrade';
      proxy_set_header Host $host;
      proxy_cache_bypass $http_upgrade;
    }
	##
	# for voucher
	##
	location = /vouch-auth {
	  # This address is where Vouch will be listening on
	  proxy_pass http://voucher-service:5000/auth;
	  proxy_pass_request_body off; # no need to send the POST body

	  proxy_set_header Content-Length "";
	  proxy_set_header X-Real-IP $remote_addr;
	  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	  proxy_set_header X-Forwarded-Proto $scheme;

	}


	# use voucher to call fence/user/anyaccess and create a simplified jwt token
	location /user-test {
	  auth_request /vouch-auth;
	  auth_request_set $authorization $upstream_http_authorization;
	  # voucher returns a simplified jwt token
	  proxy_pass http://voucher-service:5000/user;
	  proxy_set_header Authorization $authorization;
	  proxy_pass_header  Authorization;
	}
	##
	# for workspace
	##
	location /lw-workspace/ {
	    rewrite /lw-workspace/(.*) /$1 break;
	    proxy_pass http://hatchery-service:5000/;
	    proxy_http_version 1.1;
	    proxy_set_header Host $host;
	    proxy_set_header X-Real-IP $remote_addr;
	    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	    proxy_set_header Upgrade $http_upgrade;
	    proxy_set_header Connection $http_connection;
	    proxy_set_header Authorization "$access_token";
	    client_max_body_size 0;
	}

	# cadvisor
	location /cadvisor/ {
		proxy_pass http://cadvisor:8080/;
		proxy_redirect ~^/containers/ /cadvisor/containers/;
		proxy_redirect ~^/docker/ /cadvisor/docker/;
		proxy_redirect ~^/metrics/ /cadvisor/metrics/;
	}

	##
	# for certbot challenge
	##
  location /.well-known/acme-challenge/ {
      root /var/www/certbot;
  }

}
