FROM golang:1.22.1-alpine AS doh-builder
LABEL maintainer="Xueyuan, Jiang <alexxyjiang@gmail.com>"

RUN apk add --no-cache git make jq curl
WORKDIR /src

RUN set -x ;\
    DOH_VERSION_LATEST="$(curl -s https://api.github.com/repos/m13253/dns-over-https/tags|jq -r '.[0].name')" \
    && curl -L "https://github.com/m13253/dns-over-https/archive/${DOH_VERSION_LATEST}.zip" -o doh.zip \
    && unzip doh.zip \
    && rm doh.zip \
    && cd dns-over-https* \
    && make doh-server/doh-server \
    && mkdir /dist \
    && cp doh-server/doh-server /dist/doh-server \
    && echo ${DOH_VERSION_LATEST} > /dist/doh-server.version

FROM alpine:3.19
COPY --from=doh-builder /dist /server
COPY ./doh-server.conf /server/doh-server.conf
CMD [ "/server/doh-server", "-conf", "/server/doh-server.conf" ]
