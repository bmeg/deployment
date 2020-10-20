DC="docker-compose -f docker-compose.yml -f compose-services/docker-compose.yml  -f compose-services/onprem/docker-compose.yml"
$DC exec nginx nginx -s reload
echo `date` nginx reloaded
