FROM golang:1.8 AS build-env
LABEL maintainer="Paulo Costa <paulo.costa@fccn.pt>"

RUN mkdir -p /go/src/app
COPY . /go/src/app

WORKDIR /go/src/app

# download the dependencies and build the application
RUN go-wrapper download
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go-wrapper install

FROM alpine:latest AS runtime-env

ARG APP_TOKEN=f9403fc5f537b4ab332d
ARG UPLOAD_DIR=/home/educast_upload/uploads
ENV APP_TOKEN=${APP_TOKEN}

COPY --from=build-env /go/bin/app /usr/local/bin/app

WORKDIR ${UPLOAD_DIR}

# Change TimeZone
RUN apk --no-cache add ca-certificates && update-ca-certificates \
  && apk add --update tzdata \
  && cp /usr/share/zoneinfo/Europe/Lisbon /etc/localtime \
  && rm -rf /var/cache/apk/*

#add upload user
RUN addgroup -g 1000 educastgroup \
  && adduser -u 1028 -G educastgroup -D educast_upload \
  && chown -R educast_upload:educastgroup ${UPLOAD_DIR}

USER educast_upload

CMD ["sh","-c","app -token $APP_TOKEN /home/educast_upload/uploads"]