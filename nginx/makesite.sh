#!/bin/bash

set -e

# get the configuration and export it
if [ -z "$BMEG_SITE_BRANCH" ] || [ -z "$SERVER_NAME" ] || [ -z "$BASE_URL" ]; then
    source ../secrets/nginx.env;
fi
echo Building bmeg site branch=$BMEG_SITE_BRANCH for server $SERVER_NAME
# ensure the docker image that does the build is up to date
cd site-builder
docker build -t site-builder .
cd ..
# build it
echo Cloning static site ..................
rm -rf bmeg-site/$SERVER_NAME || true
git clone https://github.com/bmeg/bmeg-site bmeg-site/$SERVER_NAME
chmod -R +rw bmeg-site/$SERVER_NAME
chgrp -R sudo bmeg-site/$SERVER_NAME
cd bmeg-site/$SERVER_NAME ;
  git fetch --all ; git checkout $BMEG_SITE_BRANCH ; git pull origin $BMEG_SITE_BRANCH
  echo Setting base url in hugo config ..................
  sed -i.bak 's~baseURL:.*~baseURL: '$BASE_URL'/~' config.yaml
  docker run --rm -v $PWD:/bmeg/bmeg-site site-builder make build
  echo done
