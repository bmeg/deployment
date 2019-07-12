#!/bin/sh -e

if [ -z "${SERVER_NAME}" ]; then
  echo "SERVER_NAME is not set"
  exit 1
fi

if [ -z "${GRIP_SERVER}" ]; then
  echo "GRIP_SERVER is not set"
  exit 1
fi

if [ -z "${NGO_CLIENT_ID}" ]; then
  echo "NGO_CLIENT_ID is not set"
  exit 1
fi

if [ -z "${NGO_CLIENT_SECRET}" ]; then
  echo "NGO_CLIENT_SECRET is not set"
  exit 1
fi

if [ -z "${NGO_TOKEN_SECRET}" ]; then
  echo "NGO_TOKEN_SECRET is not set"
  exit 1
fi

# Define some defaults
export NGO_CALLBACK_SCHEME=${NGO_CALLBACK_SCHEME:-https}
export NGO_CALLBACK_URI=${NGO_CALLBACK_URI-/_oauth}
export NGO_SIGNOUT_URI=${NGO_SIGNOUT_URI-/_signout}
export NGO_EMAIL_AS_USER=${NGO_EMAIL_AS_USER:-true}
export NGO_EXTRA_VALIDITY=${NGO_EXTRA_VALIDITY:-0}
export NGO_USER=${NGO_USER:-unknown}


# Help people spot problems
if [ "${DEBUG}" ]; then
  echo "## /etc/nginx/nginx.conf ##"
  cat -n /etc/nginx/nginx.conf
  echo "## /etc/nginx/sites-enabled ##"
  ls -l /etc/nginx/sites-enabled
  echo "## environment ##"
  env | grep '^\(NGO_.*\|LOCATIONS\|GRIP_SERVER\|RESOLVER_ADDRESS\|SERVER_NAME\)=' | sort -n | cat -n
fi

# exec nginx -g "daemon off;" -c /etc/nginx/nginx.conf

# check for new certs every 6 hours
while :; do sleep 6h & wait ${!}; nginx -s reload; done & nginx -g "daemon off;" -c /etc/nginx/nginx.conf
