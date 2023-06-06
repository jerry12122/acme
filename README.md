# 使用 acme.sh 加上 Docker 獲得 ZeroSSL 免費憑證

## 簡介

通過[acme.sh](https://github.com/acmesh-official/acme.sh)工具，加上 DNS API 與免費憑證簽發機構 ZeroSSL，包裝成 Docker 容器排程執行，實現自動更新的 SSL 憑證的服務。

## 教程

## 從 Github 把專案拉下來

```bash
git clone https://github.com/jerry12122/acme.git
cd acme
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

將 `/path/to/cert` 改成存放憑證的路徑

```yml
version: "3.9"
services:
  acme-sh:
    image: ghcr.io/jerry12122/acme:latest
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

## 啟動容器

```bash
docker-compose up -d 
```

## 管理憑證
1. 執行下面指令就可以根據指示做憑證管理
```bash
docker exec -it acme-sh ./cert.sh
```
```
#############################################
       憑證管理
#############################################
     1  列出憑證
     2  新增憑證
     3  移除憑證
     4  離開
#############################################
請選擇操作:
```