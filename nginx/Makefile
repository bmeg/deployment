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


ifndef GRIP_SERVER
$(error GRIP_SERVER is not set)
endif

website:
	echo Cloning static site ..................
	rm -rf bmeg-site || true
	git clone https://github.com/bmeg/bmeg-site
	cd bmeg-site \
	  git fetch --all ; git checkout $(BMEG_SITE_BRANCH) \
	  echo Setting base url in hugo config .................. \
          sed -i.bak 's~baseURL:.*~baseURL: $(BASE_URL)/~' config.yaml \
	  docker run -v $PWD:/bmeg/bmeg-site site-builder make clean build \
	  echo copying static site to nginx .................. \
	  rm -rf ../docker/etc-nginx/public || true \
	  cp -r public ../docker/etc-nginx/public 

clean:
	rm -r docker/etc-nginx/public || true
