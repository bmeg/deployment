FROM python:3.7.2

# creates a CLI environment:
# * python 3.7.2 environment
# * mounts gs://data.bmeg.io on /data.bmeg.io
# Uses service_account_email argument and config/service_account.json

ARG service_account_email

# install gcsfuse
RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-jessie main" | tee /etc/apt/sources.list.d/gcsfuse.list; \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
  apt-get update ; apt-get install -y apt-utils kmod && apt-get install -y gcsfuse

# install google utilities, ensure they are on path
RUN curl https://sdk.cloud.google.com | bash
ENV PATH=$PATH:/root/google-cloud-sdk/bin
RUN gcloud config set disable_usage_reporting true

# authenticate
# COPY config /config
# RUN gcloud auth activate-service-account \
#  $service_account_email \
#   --key-file=/config/service_account.json --project=bmeg-io
VOLUME ["/config"]

# mount and sleep forever
COPY docker-start.sh /docker-start.sh
ENTRYPOINT ["/docker-start.sh"]
