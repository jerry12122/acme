# 使用 acme.sh 加上 Docker 獲得 ZeroSSL 免費憑證

## 簡介

通過[acme.sh](https://github.com/acmesh-official/acme.sh)工具，加上 DNS API 與免費憑證簽發機構 ZeroSSL，包裝成 Docker 容器排程執行，實現自動更新的 SSL 憑證的服務。

## 教程

## 從 Github 把專案拉下來

```bash
git clone https://github.com/jerry12122/acmeCF.git
cd acmeCF
```

## 建立.env

```bash
cp env.sample .env
```

## 編輯.env

- ACME_EMAIL: 跟域名機構申請域名使用的 email
- CF_Token: [Clouflare 申請 API Token](https://dash.cloudflare.com/profile/api-tokens)
- CF_Account_ID: 在 Cloudflare 域名概觀頁面取得
- TELEGRAM_BOT_APITOKEN: Telegram 通知 Bot 的 Token
- TELEGRAM_BOT_CHATID: Telegram 通知用戶的 Chat ID
- HTTPS_INSECURE: ssl 報錯處理

```
# 必要
ACME_EMAIL=email@example.com
# dns_api參數
CF_Token=1111111111111111111111111111
CF_Account_ID=1111111111111111111111111111
DPI_Id=123
DPI_Key=1111111111111111111111111111
# 更新Telegram Bot通知
TELEGRAM_BOT_APITOKEN="1111111:aaaaaaaaaaaaaaaaaaaaaaa"
TELEGRAM_BOT_CHATID="1111111"
# ACME出現報錯時新增 Please refer to https://curl.haxx.se/libcurl/c/libcurl-errors.html for error code: 60
# HTTPS_INSECURE=1
```

## 編輯 docker-compose.yml

將 `/path/to/cert` 改成存放頻證的路徑

```yml
version: "3.9"
services:
  acme-sh:
    build: .
    image: acme-sh
    tty: true
    stdin_open: true
    container_name: acme-sh
    restart: always
    env_file:
      - .env
    volumes:
      - /path/to/cert:/cert
      - /path/to/config:/root/.acme.sh
    network_mode: host
```

## 編譯及啟動容器

```bash
docker-compose up -d --build
```

## 新增要安裝的憑證

用法: `docker exec -it acme-sh ./init.sh 憑證存放位置 dns_api 域名1 域名2...`  
例如: 使用 Cloudflare 託管的域名 `example.com` ，憑證存放在`example.com`目錄下

1. 執行下面指令

```bash
docker exec -it acme-sh ./init.sh /cert/example.com dns_cf example.com
```

2. 就會印出下面兩行指令

```bash
/usr/bin/acme.sh --server zerossl --register-account -m email@example.com --issue --force --log --dns dns_cf -d example.com

/usr/bin/acme.sh --install-cert --key-file /cert/example.com/cert.key --fullchain-file /cert/example.com/cert.pem --log -d example.com
```

3. 將其前方加入`docker exec -it acme-sh `，改為下方指令並執行

```bash
docker exec -it acme-sh /usr/bin/acme.sh --server zerossl --register-account -m email@example.com --issue --force --log --dns dns_cf -d example.com

docker exec -it acme-sh /usr/bin/acme.sh --install-cert --key-file /cert/example.com/cert.key --fullchain-file /cert/example.com/cert.pem --log -d example.com
```

4. 完成
