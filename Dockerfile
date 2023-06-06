FROM debian:buster-slim

RUN ln -s /bin/bash /usr/bin/bash
# 安装所需软件包
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl tar vim openssl cron \
    && rm -rf /var/lib/apt/lists/*

# 设置时区
ENV TZ=Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

WORKDIR /app

# 复制文件并设置文件权限
COPY ./*.sh /app/
RUN chmod +x /app/*.sh && \

# 添加Cron任务
RUN service cron start && \
echo "0 0 * * *" "/usr/bin/acme.sh --cron" >> mycron && \
crontab mycron && \
rm mycron

# 启动Cron守护进程
CMD ["cron", "-f"]

# 设置入口点
ENTRYPOINT ["/bin/sh", "-c", "/app/entry.sh"]
