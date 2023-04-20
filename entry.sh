#!/bin/bash

# install acme.sh
if  [[ ! -f /root/.acme.sh/acme.sh ]]
then
  curl -sSL https://get.acme.sh  | sh -s email=$ACME_EMAIL
fi
if  [[ ! -f /usr/bin/acme.sh ]]
then
  ln -s /root/.acme.sh/acme.sh /usr/bin/acme.sh
  echo [$(date)]  acme.sh has been installed
  acme.sh --set-default-ca --server zerossl
fi
service cron start
# install set notify
/usr/bin/acme.sh --set-notify --notify-level 3
/usr/bin/acme.sh --set-notify --notify-mode 0
/usr/bin/acme.sh --set-notify --notify-hook telegram

# logging
if [[ ! -f /root/.acme.sh/acme.sh.log ]]; then
  touch /root/.acme.sh/acme.sh.log
fi
tail -f /root/.acme.sh/acme.sh.log
