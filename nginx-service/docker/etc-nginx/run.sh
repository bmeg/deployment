#!/bin/sh -e

RESOLVER_ADDRESS=${RESOLVER_ADDRESS:-8.8.8.8}

sed "s/%resolver_address%/${RESOLVER_ADDRESS}/" -i /etc/nginx/sites-available/default
sed "s/arachne.compbio.ohsu.edu/${GRIP_SERVER}/" -i /etc/nginx/snippets/demo-locations.conf

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

# Overwrite user supplied locations
if [ "${LOCATIONS}" ]; then
  echo "${LOCATIONS}" > /etc/nginx/snippets/demo-locations.conf
fi

# Help people spot problems
if [ "${DEBUG}" ]; then
  echo "## /etc/nginx/sites-available/default ##"
  cat -n /etc/nginx/sites-available/default
  echo "## /etc/nginx/snippets/demo-locations.conf ##"
  cat -n /etc/nginx/snippets/demo-locations.conf
  echo "## environment ##"
  env | grep '^\(NGO_.*\|LOCATIONS\|GRIP_SERVER\)=' | sort -n | cat -n
fi

#certbot --nginx -m ${LETSENCRYPT_EMAIL} --agree-tos  -d ${BASE_URL} --noninteractive
exec nginx -g "daemon off;" -c /etc/nginx/nginx.conf