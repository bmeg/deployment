source  ../nginx.env ; export $(cut -d= -f1 ../nginx.env) ;
cd site-builder
docker build -t site-builder .
cd ..
echo Cloning static site ..................
rm -rf bmeg-site || true
git clone https://github.com/bmeg/bmeg-site
chmod -R +rw bmeg-site
chgrp -R sudo bmeg-site
cd bmeg-site ;
  git fetch --all ; git checkout $BMEG_SITE_BRANCH ; git pull origin $BMEG_SITE_BRANCH
  echo Setting base url in hugo config ..................
  sed -i.bak 's~baseURL:.*~baseURL: '$BASE_URL'/~' config.yaml
  docker run --rm -v $PWD:/bmeg/bmeg-site site-builder make build
  echo done
