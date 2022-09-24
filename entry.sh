#!/bin/bash
curl -sSL https://get.acme.sh | sh -s email=$ACME_EMAIL
ln -s /root/.acme.sh/acme.sh /usr/bin/acme.sh
acme.sh --set-default-ca --server letsencrypt
crontab -l > mycron
for i in $(echo $DOMAIN | tr ";" "\n")
do
    echo "0 0 * * * acme.sh  --home /acme --server letsencrypt --issue  --dns dns_cf  $i --force >> /log/acme.log" >> mycron
done
crontab -r
crontab mycron
rm mycron
mkdir -p /log
touch /log/acme.log
tail -f /log/acme.log