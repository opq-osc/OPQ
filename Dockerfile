FROM alpine:latest AS build
WORKDIR /apps
ARG version
ARG TARGETPLATFORM
RUN apk add wget \
    && echo "https://github.com/opq-osc/OPQ/releases/download/v${version}/OPQBot_${version}_linux_$(echo -e $TARGETPLATFORM | sed -e 's/linux\///g' -e 's/\/7//g').tar.gz" \
	&& wget --no-check-certificate -c -O /apps/tmp.tar.gz "https://github.com/opq-osc/OPQ/releases/download/v${version}/OPQBot_${version}_linux_$(echo $TARGETPLATFORM | sed -e 's/linux\///g' -e 's/\/v7//g').tar.gz"\
	&& tar -xvf tmp.tar.gz\
	&& mv OPQBot* opqbot

FROM alpine:latest
LABEL MAINTAINER enjoy<i@mcenjoy.cn>


WORKDIR /apps
COPY --from=build /apps/opqbot/ /apps/
COPY ./entrypoint.sh /apps/entrypoint.sh
# 设置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone

# 设置编码
ENV LANG C.UTF-8

EXPOSE 8086


RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 && chmod +x /apps/entrypoint.sh

VOLUME [ "/apps/UsersConf" ]

# 开RUN
ENTRYPOINT ["/apps/entrypoint.sh"]