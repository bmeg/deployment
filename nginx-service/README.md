### Pre-requisites


### Pre-requisites
Assumes:
* Ubuntu 18.10 on GCP.
* You have a DNS entry


```
sudo snap install docker
sudo addgroup --system docker
sudo adduser $USER docker
newgrp docker
sudo snap disable docker
sudo snap enable docker
docker ps
sudo apt update
sudo apt install make
sudo apt install hugo
sudo apt install npm

$ hugo version
Hugo Static Site Generator v0.47.1/extended linux/amd64 BuildDate: 2018-09-25T03:41:10Z

$ docker --version
Docker version 18.06.1-ce, build e68fc7a

$ npm --version
5.8.0

$ make --version
GNU Make 4.2.1
```


### setup

```
# install software as user `ubuntu`
sudo su - ubuntu

# clone repo into /opt
cd /opt
sudo git clone https://github.com/bmeg/bmeg
sudo chown -R  ubuntu:ubuntu  bmeg
#
cd bmeg/nginx-service

```

Before continuing, setup your oauth server
![image](https://user-images.githubusercontent.com/47808/50254570-69238980-03a3-11e9-9dd8-4e592a3289e4.png)



```
cat <<'EOF'  >>.env
export DNS=<your-hostname.com>
export BASE_URL=https://$DNS
export RESOLVER_ADDRESS=8.8.8.8
export BMEG_SITE_BRANCH=master
export GRIP_SERVER=<location of grip server>
export LETSENCRYPT_EMAIL=<YOUR-EMAIL>

# OAUTH see NGINX-README.md for more
export NGO_CALLBACK_SCHEME=https
export NGO_CLIENT_ID=<CLIENT ID>
export NGO_CLIENT_SECRET=<SECRET>
export NGO_TOKEN_SECRET=<SECRET>

EOF
```

Before continuing, run the letsencrypt certbot and place the resulting directory in `nginx-service/docker/etc-letsencrypt/`


# RUN

make run
