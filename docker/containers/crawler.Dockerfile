FROM alpine:3.7

RUN apk add --no-cache bash wget

RUN mkdir -p /application
COPY mirror.sh /application/mirror.sh
RUN chmod +x /application/mirror.sh
WORKDIR /application

CMD ["time", "bash", "./mirror.sh"]
