.DEFAULT_GOAL := website

ifndef BASE_URL
$(error BASE_URL is not set)
endif

ifndef RESOLVER_ADDRESS
$(error RESOLVER_ADDRESS is not set)
endif

ifndef NGO_CALLBACK_SCHEME
$(error NGO_CALLBACK_SCHEME is not set)
endif

ifndef NGO_CLIENT_ID
$(error NGO_CLIENT_ID is not set)
endif

ifndef NGO_CLIENT_SECRET
$(error NGO_CLIENT_SECRET is not set)
endif

ifndef NGO_TOKEN_SECRET
$(error NGO_TOKEN_SECRET is not set)
endif

ifndef BMEG_SITE_BRANCH
$(error BMEG_SITE_BRANCH is not set)
endif

ifndef PORT
$(error PORT is not set)
endif

ifndef GRIP_SERVER
$(error GRIP_SERVER is not set)
endif

website:
	echo Cloning static site ..................
	cd ~ && rm -rf bmeg-site || true
	cd ~ && git clone https://github.com/bmeg/bmeg-site
	cd ~/bmeg-site && git fetch --all && git checkout $(BMEG_SITE_BRANCH)
	echo Setting base url in hugo config ..................
	cd ~/bmeg-site && sed -i.bak 's~baseURL:.*~baseURL: $(BASE_URL)/~' config.yaml
	cd ~/bmeg-site && hugo


nginx: website
	echo copying static site to nginx ..................
	rm -rf docker/etc-nginx/public || true
	cp -r ~/bmeg-site/public docker/etc-nginx/public

build: nginx
	echo building docker .......
	docker build -t bmeg-nginx .

run: build
	docker run --rm -it -p $(PORT):$(PORT) -p 80:80 \
	-e DEBUG=1  \
	-e RESOLVER_ADDRESS=$(RESOLVER_ADDRESS) \
	-e NGO_CALLBACK_SCHEME=https \
	-e NGO_CLIENT_ID=$(NGO_CLIENT_ID) \
	-e NGO_CLIENT_SECRET=$(NGO_CLIENT_SECRET) \
	-e NGO_TOKEN_SECRET=$(NGO_TOKEN_SECRET) \
	-e GRIP_SERVER=$(GRIP_SERVER) \
	-e LETSENCRYPT_EMAIL=$(LETSENCRYPT_EMAIL) \
	-e BASE_URL=$(BASE_URL) \
	-e PORT=$(PORT) \
	-v $(CURDIR)/docker/etc-letsencrypt:/etc/letsencrypt \
	bmeg-nginx:latest

clean:
	rm -r docker/etc-nginx/public
	docker rmi bmeg-nginx
