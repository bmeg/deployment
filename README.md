overview
----

![image](https://user-images.githubusercontent.com/47808/61062751-9d987a80-a3b3-11e9-8243-7431c0f3f17c.png)

This repository contains nginx and static file setup for:

* bmeg public site  https://bmeg.io
* bmeg data directory https://bmeg.io/bmeg-data
* secure access to grip server https://bmeg.io/analyze/access
* secure access to recount.bio data https://recount.bio


Additionally, we maintain nginx configurations for:

* jupyterhub - for analysis  https://bmeg-jupyter.ddns.net
* cadvisor - for devops statistics https://bmeg-jupyter.ddns.net/cadvisor
* gen3 - example arbitrary other content https://gen3-ohsu.ddns.net

Each site (domain) is backed by a letsencrypt certbot certificate renewal process.


deployment
-----

* databases and docker workareas live on : /mnt/data1/...
* repositories, etl and configurations live on : /mnt/data2/...





structure
----

### nginx

The nginx service leverages two key technologies:
* certbot and a shared volume `data/`
  * provides signed valid certs for multiple sites
* [cloudflare/nginx-google-oauth](https://github.com/cloudflare/nginx-google-oauth)
  * implements google oauth, implemented for external connections to the `grip` server
  * see `secrets/nginx.env` for parameters, matched with ['bmeg' gcp](https://console.cloud.google.com/apis/credentials?project=bmeg-io)
* The `run.sh` script launches nginx within its container
  * The script will reload the config and certs every 6 hours.
  * The `DEBUG` env variable controls parameter logging


  ```
    nginx
    ├── Dockerfile
    ├── etc
    │   └── nginx
    │       ├── conf.d
    │       │   ├── default.conf
    │       │   └── protected.conf
    │       ├── grip.conf
    │       ├── http.conf.d
    │       │   └── env.conf
    │       ├── lua
    │       │   └── nginx-google-oauth
    │       ├── nginx.conf
    │       ├── protected.conf
    │       ├── sites-available
    │       │   └── default
    │       └── sites-enabled
    │           ├── bmeg.io
    │           ├── bmegio.ohsu.edu
    │           ├── bmeg-jupyter.ddns.net
    │           └── gen3-ohsu.ddns.net
    └── usr
        └── share
            └── nginx
                ├── default
                └── gen3-ohsu.ddns.net
  ```


#### sites

Each site has a file in etc/nginx/sites-enabled.  Ensure that the site is included in etc/nginx/

Content is mapped to `usr/share/nginx/...`.  The `bmeg-data/` directory is mounted to /usr/share/nginx/bmeg.io.data

The bmeg-site hugo single page app is generated into `nginx/bmeg-site/bmeg.io/public` and mounted to /usr/share/nginx/bmeg.io

The `makesite.sh` script sets the base site in the hugo config and runs the docker image `site-builder`

```
├── makesite.sh
├── site-builder
│   └── Dockerfile
```

To update the content:
```
DEPLOYMENT_DIR=/mnt/data2/bmeg/deployment
cd $DEPLOYMENT_DIR
alias dc='docker-compose -f docker-compose.yml -f compose-services/docker-compose.yml  -f compose-services/onprem/docker-compose.yml'

cd nginx
./makesite.sh
cd ..
$dc build nginx
$dc stop nginx
$dc rm -f nginx
$dc up -d
```

### certbot

The `init-letsencrypt.sh` cli tool :
* creates temporary self signed certs
* requests the letsencrypt certificate
* maintains shared convention to `data/` with the `certbot` and `nginx` services.  See volume mapping docker-compose.yml
* certbot will check renewal for each domain cert every 12 hours

```
init-letsencrypt.sh     // cli tool
data                    // letsencrypt data
└── certbot
    ├── conf
    │   ├── accounts
    │   │   └── acme-v02.api.letsencrypt.org
    │   ├── archive
    │   │   ├── bmegio.ohsu.edu
    │   │   ├── bmeg-jupyter.ddns.net
    │   │   └── gen3-ohsu.ddns.net
    │   ├── csr
    │   │   ├── 0000_csr-certbot.pem
    │   │   └── ....
    │   ├── keys
    │   │   ├── 0000_key-certbot.pem
    │   │   └── ...
    │   ├── live
    │   │   ├── bmegio.ohsu.edu
    │   │   ├── bmeg-jupyter.ddns.net
    │   │   ├── gen3-ohsu.ddns.net
    │   │   └── README
    │   ├── options-ssl-nginx.conf
    │   ├── renewal
    │   │   ├── bmegio.ohsu.edu.conf
    │   │   ├── bmeg-jupyter.ddns.net.conf
    │   │   └── gen3-ohsu.ddns.net.conf
    │   ├── renewal-hooks
    │   │   ├── deploy
    │   │   ├── post
    │   │   └── pre
    │   └── ssl-dhparams.pem
    └── www
```

#### creating a new host

To create a new host, in this example `bmeg.io`

First, point the DNS at this host.  Once that is verified, ask letsencrypt for new certs.
```
sudo  ./init-letsencrypt.sh  bmeg.io
```
This should respond with a "congratulations" message.


#### updating the bmeg.io website

bash convenience
```
#  stop, rebuild, start and montitor
alias dc='docker-compose '
rs() {
  dc stop $1; dc rm -f $1; dc build $1; dc up -d $1; dc logs -f $1
}
```

```
# in the nginx dir, build the new site.
cd nginx/
export SERVER_NAME=bmeg.io
export BASE_URL=https://bmeg.io
export BMEG_SITE_BRANCH=master
./makesite.sh

# restart nginx
cd ..
rs nginx

```


### mongo
Plain vanilla mongo installation.  Data maintained on `/mnt/data1/bmeg/mongo-data`


### grip

See `secrets/grip_config.yml` for configuration.
It's default schema is mapped from `bmeg-site/static/meta/schema.json`



### jupyterhub

The nginx service leverages two key technologies:
* dockerspawner==0.11.1
  * see `secrets/userlist` for whitelist of users.
  * see `secrets/jupyterhub_config.py` for parameters:
    * each user's notebook is launched with cpu_limit = 1, mem_limit = '10G' and will be paused after 1 hr of inactivity
* oauthenticator==0.8.2
  * see `secrets/oauth.env` for parameters, matched with ['bmeg-jupyter' gcp](https://console.cloud.google.com/apis/credentials?project=bmeg-io)  

The `jupyterlab` image is used for notebooks.  Build via `dc build jupyterlab`

**Please Note**: While hub data is maintained in `/mnt/data1/bmeg/jupyter-data`, the lifecycle of data has **NOT been tested**.  Please back up your work.


```
├── jupyterhub
│   └── Dockerfile
├── jupyterlab
│   └── Dockerfile
├── secrets
│   ├── jupyter.env
│   ├── jupyterhub_config.py

```



### other services

#### etl

Note: exec into the grip server to drop & create graph.
The mount bmeg-etl directory, is mounted on `/bmeg-etl`.

```
├── etl                    // python 3.7 utility
│   ├── Dockerfile
│   ├── docker-start.sh
│   └── README.md

```

#### cadvisor

A streaming ui is provided at https://bmeg-jupyter.ddns.net/cadvisor.

Notes:
* the data is not persisted
* you need to log into jupyterhub before accessing

<img src="https://user-images.githubusercontent.com/47808/61067786-41d2ef00-a3bd-11e9-9ded-5d611dcb691c.png" alt="drawing" width="200"/>


#### gen3 compose-services

* setup

```
# see commons.bmeg.io
cd xxx/deployment
git status
# On branch commons.bmeg.io
git clone git@github.com:ohsu-comp-bio/compose-services.git
checkout compose-services
git checkout commons.bmeg.io
cd ..

alias dc='docker-compose -f docker-compose.yml -f compose-services/docker-compose.yml  -f compose-services/onprem/docker-compose.yml'


# build local services

cd compose-services/onprem/
make

>>>
$ docker images | grep onprem
onprem/tube                     latest              b455e7513b9f        9 minutes ago       2.11GB
onprem/data-portal              latest              552a3d09ca9c        11 minutes ago      1.22GB
onprem/hatchery                 latest              b88a0a5e39da        15 minutes ago      954MB
onprem/s3indexer                latest              1bde3a35f4cf        16 minutes ago      1.16GB
onprem/indexs3client            latest              4658ee3c14dc        17 minutes ago      10.5MB
onprem/fence                    latest              857b63840d4a        18 minutes ago      670MB


# customize gen3 secrets

cd Secrets
grep commons.bmeg.io  *.*
fence-config.yaml:BASE_URL: 'https://commons.bmeg.io/user'
peregrine_creds.json:  "hostname": "commons.bmeg.io"
sheepdog_creds.json:  "hostname": "commons.bmeg.io",


cd ..

# prep for elastic
sysctl -w vm.max_map_count=262144

# install yp needed by creds_setup.sh
# see https://mikefarah.gitbook.io/yq/#on-ubuntu-16-04-or-higher-from-debian-package



# generate local certs
$ bash ./creds_setup.sh  commons.bmeg.io

>>>
The Subject's Distinguished Name is as follows
...
commonName            :ASN.1 12:'<hostname>'
...
Write out database with 1 new entries
Data Base Updated


# configure keys
check `Secrets/fenceJwtKeys/<now() timestamp>/`  fence will use most recent timestamp

# copy fence's public key to elastic  Secrets/elasticsearch-open-distro/config.yml
# see jwt_auth_domain/signing_key  
# see voucher-service in compose-services/onprem/docker-compose.yml

update compose-services/Secrets/.env

# slow start order (use this if you are having problems), otherwise skip to next

dc up -d postgres
dc up -d fence-service
dc up -d arborist-service
dc exec fence-service fence-create migrate
dc exec fence-service fence-create sync --arborist http://arborist-service --yaml user.yaml


# bring up gen3

dc up -d

# apply security config to elastic
### note: compare against top of elastic log file

dc exec esproxy-service \
"/usr/share/elasticsearch/plugins/opendistro_security/tools/securityadmin.sh" -cd "/usr/share/elasticsearch/plugins/opendistro_security/securityconfig" -icl -key "/usr/share/elasticsearch/config/kirk-key.pem" -cert "/usr/share/elasticsearch/config/kirk.pem" -cacert "/usr/share/elasticsearch/config/root-ca.pem" -nhnv

### should produce

>>>
...
Done with success

```
