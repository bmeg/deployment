.DEFAULT_GOAL := website

ifndef BASE_URL
$(error BASE_URL is not set)
endif

website:
	# echo Cloning static site ..................
	# rm -rf bmeg-tutorial
	# git clone https://github.com/bmeg/bmeg-tutorial
	# echo Setting base url in hugo config ..................
	# cd bmeg-tutorial && sed -i.bak s~https://bmeg.github.io/~$(BASE_URL)~ config.yaml
	# cd bmeg-tutorial && hugo
	# echo copying static site to nginx ..................
	# cp -r bmeg-tutorial/public docker/etc-nginx/public
	rm -rf ~/bmeg-site/public
	echo Setting base url in hugo config ..................
	cd ~/bmeg-site && sed -i.bak s~https://bmeg.github.io/~$(BASE_URL)~ config.yaml
	cd ~/bmeg-site && hugo
	echo copying static site to nginx ..................
	cp -r ~/bmeg-site/public docker/etc-nginx/public

build-docker: website
	echo building docker .......
	docker build -t bmeg-nginx .

run-docker: build-docker
	docker run --rm -it -p 80:80 \
	-e DEBUG=1  \
	-e RESOLVER_ADDRESS=137.53.223.44 \
	-e NGO_CALLBACK_SCHEME=http \
	-e NGO_CLIENT_ID="625358568374-6hl80la773la7fdbduoufm2i5ajn6fho.apps.googleusercontent.com" \
	-e NGO_CLIENT_SECRET="--8sqcdQeDYADwqMPhV38dry" \
	-e NGO_TOKEN_SECRET="zKzxBPTFHCHkHfQFyLKDrdkV7" \
	bmeg-nginx:latest

clean:
	rm -r docker/etc-nginx/public
