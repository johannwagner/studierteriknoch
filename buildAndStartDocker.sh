docker build -t studierteriknoch .

docker run --name studierteriknoch -d -p 80:80 -p 443:443 -v /etc/letsencrypt/live/studierteriknoch.de/fullchain.pem:/fullchain.pem -v /etc/letsencrypt/live/studierteriknoch.de/privkey.pem:/privkey.pem studierteriknoch
