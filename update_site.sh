DEPLOYMENT_DIR=/mnt/data2/bmeg/deployment
NGINX_DIR=nginx-open
cd $DEPLOYMENT_DIR
dc='docker-compose'

cd $NGINX_DIR
sudo rm -rf bmeg-site
./makesite.sh
cd ..
$dc build nginx
$dc stop nginx
$dc rm -f nginx
$dc up -d
