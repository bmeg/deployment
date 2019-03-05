Staging

* pr auth - python client


* docker-compose
* fuse



# Container-Optimized OS

* see https://cloud.google.com/container-optimized-os/docs/concepts/security#filesystem

```
# $109.44 monthly estimate
# 4 cpu ,  26 GB ,  10GB standard, 200GB ssd

gcloud beta compute --project=bmeg-io instances create staging-6 --zone=us-west1-b --machine-type=n1-highmem-4 --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=340847348510-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=https-server --image=cos-beta-73-11647-64-0 --image-project=cos-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=staging-6 --create-disk=mode=rw,size=200,type=projects/bmeg-io/zones/us-west1-b/diskTypes/pd-ssd,name=ssd-6
```

# --------
# setup ssd https://cloud.google.com/compute/docs/disks/local-ssd
# --------
# list devices
lsblk
# >> sdb

# format ssd
sudo mkfs.ext4 -F /dev/sdb

# create directory to mount ssd
sudo mkdir -p /mnt/disks/bmeg

# mount it, disable slow write cache
sudo mount -o discard,defaults,nobarrier /dev/sdb  /mnt/disks/bmeg

# Configure read and write access to the device
sudo chmod a+w /mnt/disks/bmeg

# Create the /etc/fstab entry.
# check the by-id/..... seems to change
echo UUID=`sudo blkid -s UUID -o value /dev/disk/by-id/google-persistent-disk-1` /mnt/disks/bmeg ext4 discard,defaults,[NOFAIL_OPTION] 0 2 | sudo tee -a /etc/fstab
# cat /etc/fstab
# UUID=7073ecee-9c69-40c8-8c77-846c4f92b6f7 /mnt/disks/bmeg ext4 discard,defaults,[NOFAIL_OPTION] 0 2


# -------
# Install Docker Compose
# see https://cloud.google.com/community/tutorials/docker-compose-on-container-optimized-os
# -------

alias dc='docker run --rm     -v /var/run/docker.sock:/var/run/docker.sock     -v "/mnt/disks/bmeg:/bmeg"     -w="/bmeg"     docker/compose:1.23.0'
source ~/.bashrc

# dc version
# docker-compose version 1.23.0, build c8524dc1
# docker-py version: 3.5.0
# CPython version: 3.6.7
# OpenSSL version: OpenSSL 1.1.0f  25 May 2017


```
FROM python:3.7.2

ARG service_account_email

RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-jessie main" | tee /etc/apt/sources.list.d/gcsfuse.list; \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
  apt-get update ; apt-get install -y apt-utils kmod && apt-get install -y gcsfuse

RUN curl https://sdk.cloud.google.com | bash

ENV PATH=$PATH:/root/google-cloud-sdk/bin

RUN gcloud config set disable_usage_reporting true

COPY config /config
COPY docker-start.sh /docker-start.sh

RUN gcloud auth activate-service-account \
  $service_account_email \
  --key-file=/config/service_account.json --project=bmeg-io

ENTRYPOINT ["/docker-start.sh"]

```


```
#!/usr/bin/env bash

# create data dir
mkdir -p /data.bmeg.io
gcsfuse --implicit-dirs \
  --key-file=/config/service_account.json \
  data.bmeg.io  /data.bmeg.io

echo '/data.bmeg.io mounted'

# pause forever
cat < /dev/null

```

```
docker build \
  --build-arg service_account_email=340847348510-compute@developer.gserviceaccount.com \
  -t python3.7 .

docker run --privileged -d  --name etl python3.7
```

```
mkdir /mnt/disks/bmeg/mongo-data
docker run --name mongo  -v /mnt/disks/bmeg/mongo-data:/data/db -d mongo:3.6
```
