FROM --platform=${BUILDPLATFORM} golang:1.23-alpine3.21 AS doh-builder
LABEL maintainer="Xueyuan, Jiang <alexxyjiang@gmail.com>"
ENV LANG="C.UTF-8" LC_ALL="C.UTF-8"
RUN apk update \
  && apk add --no-cache make patch curl jq
WORKDIR /src
COPY Makefile.patch /src/Makefile.patch
RUN set -x ;\
    DOH_VERSION_LATEST="$(curl -s https://api.github.com/repos/m13253/dns-over-https/tags | jq -r '.[0].name')" \
    && curl -L "https://github.com/m13253/dns-over-https/archive/${DOH_VERSION_LATEST}.zip" -o doh.zip \
    && unzip doh.zip \
    && rm doh.zip
ARG TARGETOS TARGETARCH
RUN cd /src/dns-over-https* \
    && patch < /src/Makefile.patch \
    && make GOOS=${TARGETOS} GOARCH=${TARGETARCH} doh-server/doh-server \
    && mkdir /dist \
    && cp doh-server/doh-server /dist/doh-server

FROM alpine:3.21
COPY --from=doh-builder /dist /server
COPY ./doh-server.conf /server/doh-server.conf
CMD [ "/server/doh-server", "-conf", "/server/doh-server.conf" ]
