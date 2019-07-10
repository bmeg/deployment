

## create self signed cert

```
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout etc/ssl/private/bmegio.ohsu.edu.key -out etc/ssl/certs/bmegio.ohsu.edu.crt -config bmegio.ohsu.edu.conf
```
