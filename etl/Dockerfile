FROM python:3.7.2

# creates a CLI environment:
# * python 3.7.2 environment
# * mounts gs://data.bmeg.io on /data.bmeg.io
# Uses service_account_email argument and config/service_account.json

ARG SERVICE_ACCOUNT_EMAIL

# install gcsfuse
RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-jessie main" | tee /etc/apt/sources.list.d/gcsfuse.list; \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
  apt-get update ; apt-get install -y apt-utils kmod && apt-get install -y gcsfuse

# install google utilities, ensure they are on path
RUN curl https://sdk.cloud.google.com | bash
ENV PATH=$PATH:/root/google-cloud-sdk/bin
RUN gcloud config set disable_usage_reporting true


# install mongo import
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
RUN echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list
RUN apt-get update
RUN apt-get install -y mongodb-org-tools

# authenticate using SERVICE_ACCOUNT_EMAIL and /config/service_account.json,   mount and sleep forever
VOLUME ["/config"]
COPY docker-start.sh /docker-start.sh
ENTRYPOINT ["/docker-start.sh"]
