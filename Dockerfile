FROM golang:1.15-alpine as Build
ARG VERSION='4.31.0'
RUN apk add --no-cache git build-base
RUN wget -O - https://github.com/v2ray/v2ray-core/archive/v${VERSION}.tar.gz | tar -xz -C / && mv /v2ray-core-${VERSION} /v2ray
WORKDIR /v2ray
RUN go mod vendor
RUN set -e \
  && cd /v2ray/main \
  && go build  -mod=vendor -ldflags '-s -w' -o v2ray

FROM alpine:3.9@sha256:7746df395af22f04212cd25a92c1d6dbc5a06a0ca9579a229ef43008d4d1302a
# 需要安装这个 tls 证书才可以被识别
RUN apk add --no-cache ca-certificates
COPY --from=Build /v2ray/main/v2ray /usr/bin/v2ray
ENTRYPOINT [ "sh" ]
# CMD [ "-xec", "wget -O - --header='token: $token' $url | v2ray -format=pb -config=stdin:" ]
