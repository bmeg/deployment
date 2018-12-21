
client: 625358568374-6hl80la773la7fdbduoufm2i5ajn6fho.apps.googleusercontent.com
secret: --8sqcdQeDYADwqMPhV38dry


docker run --rm -it --net host \
  -e DEBUG=1 \
  -e NGO_CALLBACK_SCHEME=http \
  -e NGO_CLIENT_ID="625358568374-6hl80la773la7fdbduoufm2i5ajn6fho.apps.googleusercontent.com" \
  -e NGO_CLIENT_SECRET="--8sqcdQeDYADwqMPhV38dry" \
  -e NGO_TOKEN_SECRET="zKzxBPTFHCHkHfQFyLKDrdkV7" \
  cloudflare/nginx-google-oauth:1.1.1

docker run --rm -it -p 80:80 \
  -e DEBUG=1 \
  -e NGO_CALLBACK_SCHEME=http \
  -e NGO_CLIENT_ID="625358568374-6hl80la773la7fdbduoufm2i5ajn6fho.apps.googleusercontent.com" \
  -e NGO_CLIENT_SECRET="--8sqcdQeDYADwqMPhV38dry" \
  -e NGO_TOKEN_SECRET="zKzxBPTFHCHkHfQFyLKDrdkV7" \
  cloudflare/nginx-google-oauth:1.1.1


docker build -t nginx-google-oauth .


docker run --rm -it -p 80:80 \
  -e DEBUG=1 \
  -e NGO_CALLBACK_SCHEME=http \
  -e NGO_CLIENT_ID="625358568374-6hl80la773la7fdbduoufm2i5ajn6fho.apps.googleusercontent.com" \
  -e NGO_CLIENT_SECRET="--8sqcdQeDYADwqMPhV38dry" \
  -e NGO_TOKEN_SECRET="zKzxBPTFHCHkHfQFyLKDrdkV7" \
  nginx-google-oauth:latest



sudo snap install docker
sudo addgroup --system docker
sudo adduser $USER docker
newgrp docker
sudo snap disable docker
sudo snap enable docker
docker ps
sudo apt install make
sudo apt update ; sudo apt install hugo
