source  ../nginx.env ; export $(cut -d= -f1 ../nginx.env) ; 
cd site-builder
docker build -t site-builder .
cd ..
echo Cloning static site ..................
sudo rm -rf bmeg-site || true
git clone https://github.com/bmeg/bmeg-site
chmod -R +rw bmeg-site 
cd bmeg-site ; 
  git fetch --all ; git checkout $BMEG_SITE_BRANCH  
  echo Setting base url in hugo config ..................  
  sed -i.bak 's~baseURL:.*~baseURL: '$BASE_URL'/~' config.yaml  
  docker run --rm -v $PWD:/bmeg/bmeg-site site-builder make build  
  echo copying static site to nginx ..................  
  rm -rf ../docker/etc-nginx/public || true  
  cp -r public ../docker/etc-nginx/public
