#!/usr/bin/env bash

# authenticate
gcloud auth activate-service-account \
  $SERVICE_ACCOUNT_EMAIL\
  --key-file=/config/service_account.json --project=bmeg-io

# create data dir
mkdir -p /data.bmeg.io
gcsfuse --implicit-dirs \
  --key-file=/config/service_account.json \
  data.bmeg.io  /data.bmeg.io

echo '/data.bmeg.io mounted'

# pause forever
echo sleep infinity...
sleep infinity
