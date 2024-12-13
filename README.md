# doh-docker 
docker image for running dns-over-https, based on the go language binary project [dns-over-https](https://github.com/m13253/dns-over-https).

## multi-arch support
- [x] amd64
- [x] arm64

## build
```shell
docker pull golang:1.23-alpine3.21 && docker pull alpine:3.21 && docker build -t alexxyjiang/doh --platform linux/amd64,linux/arm64 .
```

## run
```shell
docker run -d --name doh_server --restart always --network host -v $(pwd)/doh-server.conf:/server/doh-server.conf alexxyjiang/doh:latest
```
