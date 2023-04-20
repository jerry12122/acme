FROM alpine:3.14

# 安装所需软件包
RUN apk update && apk add --no-cache \
    wget curl tar vim

# 设置时区
ENV TZ=Asia/Taipei
RUN apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

WORKDIR /app

# 复制文件并设置文件权限
COPY ./*.sh ./
RUN chmod +x ./*.sh

# 启动Cron并添加任务
RUN crond -f -d 8 && \
    echo "0 0 * * *" "/usr/bin/acme.sh --cron" >> mycron && \
    crontab mycron && \
    rm mycron

# 设置入口点
ENTRYPOINT ["/bin/sh", "-c", "/app/entry.sh"]
