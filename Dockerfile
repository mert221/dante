FROM alpine:3.7

ARG SOCKET_USER=sockd_user
ARG SOCKET_PASSWORD=sockd_passwd

RUN set -x && apk add --no-cache linux-pam curl
RUN adduser -s /bin/false -D -S -u 8062 -H $SOCKET_USER \
    && adduser -s /bin/false -D -S -u 8065 -H sockd

RUN set -x \
 && apk add --no-cache -t .build-deps \
        build-base \
        linux-pam-dev \
 && cd /tmp \
 && curl -L https://www.inet.no/dante/files/dante-1.4.2.tar.gz | tar xz \
 && cd dante-* \
 && ac_cv_func_sched_setscheduler=no ./configure \
 && make install \
 && cd / \
 && rm -rf /tmp/* \
 && apk del --purge .build-deps

RUN set -x \
    && curl -Lo /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 \
    && chmod +x /usr/local/bin/dumb-init

RUN echo "${SOCKET_USER}:${SOCKET_PASSWORD}" | chpasswd

EXPOSE 1080

ENTRYPOINT ["dumb-init"]
CMD ["sockd"]
