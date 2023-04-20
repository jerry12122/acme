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

# 添加Cron任务
ENV CRON_COMMAND="0 0 * * * /usr/bin/acme.sh --cron"
RUN echo "${CRON_COMMAND}" >> /etc/crontabs/root

# 启动Cron守护进程
CMD ["crond", "-f", "-d", "8"]

# 设置入口点
ENTRYPOINT ["/bin/sh", "-c", "/app/entry.sh"]
