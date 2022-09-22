#!/bin/bash
curl -sSL https://get.acme.sh | sh -s email=$ACME_EMAIL
ln -s /root/.acme.sh/acme.sh /usr/bin/acme.sh
acme.sh --set-default-ca --server letsencrypt
#write out current crontab
crontab -l > mycron
#echo new cron into cron file
echo "0 0 * * * acme.sh  --home /acme --server letsencrypt --issue  --dns dns_cf  $DOMAIN --force >> /log/acme.log" >> mycron
#install new cron file
crontab mycron
rm mycron
mkdir -p /log
touch /log/acme.log
tail -f /log/acme.log