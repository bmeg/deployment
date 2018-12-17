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


website:
	echo Cloning static site ..................
	cd ~ && rm -rf bmeg-site || true
	cd ~ && git clone https://github.com/bmeg/bmeg-site
	echo Setting base url in hugo config ..................
	cd ~/bmeg-site && sed -i.bak s~baseURL:.*~baseURL: $(BASE_URL)~ config.yaml
	cd ~/bmeg-site && hugo
	echo copying static site to nginx ..................
	cp -r bmeg-site/public docker/etc-nginx/public


nginx: website
	rm -rf ~/bmeg-site/public
	echo Setting base url in hugo config ..................
	cd ~/bmeg-site && sed -i.bak s~https://bmeg.github.io/~$(BASE_URL)~ config.yaml
	cd ~/bmeg-site && hugo
	echo copying static site to nginx ..................
	cp -r ~/bmeg-site/public docker/etc-nginx/public

build-docker: nginx
	echo building docker .......
	docker build -t bmeg-nginx .

run-docker: build-docker
	docker run --rm -it -p 443:443 \
	-e DEBUG=1  \
	-e RESOLVER_ADDRESS=$(RESOLVER_ADDRESS) \
	-e NGO_CALLBACK_SCHEME=https \
	-e NGO_CLIENT_ID=$(NGO_CLIENT_ID) \
	-e NGO_CLIENT_SECRET=$(NGO_CLIENT_SECRET) \
	-e NGO_TOKEN_SECRET=$(NGO_TOKEN_SECRET) \
	bmeg-nginx:latest

clean:
	rm -r docker/etc-nginx/public
