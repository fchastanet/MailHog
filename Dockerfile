#
# MailHog Dockerfile
#

# stage 1
FROM golang:alpine

# Install MailHog:
RUN apk --no-cache add --virtual build-dependencies \
    git \
  && mkdir -p /root/gocode \
  && export GOPATH=/root/gocode \
  && git clone https://github.com/hdpe/MailHog.git /root/gocode/src/github.com/mailhog/MailHog \
  && cd /root/gocode/src/github.com/mailhog/MailHog \
  && MAILHOG_REPO_BASE=https://github.com/hdpe \
  && MAILHOG_VENDOR_BASE=vendor/github.com/mailhog \
  && rm -rf "$MAILHOG_VENDOR_BASE"/data \
  && rm -rf "$MAILHOG_VENDOR_BASE"/http \
  && rm -rf "$MAILHOG_VENDOR_BASE"/MailHog-Server \
  && rm -rf "$MAILHOG_VENDOR_BASE"/storage \
  && git clone "$MAILHOG_REPO_BASE/data" "$MAILHOG_VENDOR_BASE/data" \
  && git clone "$MAILHOG_REPO_BASE/http" "$MAILHOG_VENDOR_BASE/http" \
  && git clone "$MAILHOG_REPO_BASE/MailHog-Server" "$MAILHOG_VENDOR_BASE/MailHog-Server" \
  && git clone "$MAILHOG_REPO_BASE/storage" "$MAILHOG_VENDOR_BASE/storage" \
  && GOOS=linux go build

# stage 2
FROM alpine:latest
RUN apk --no-cache add ca-certificates

COPY --from=0 /root/gocode/src/github.com/mailhog/MailHog/MailHog /usr/local/bin
COPY MailHog-entrypoint.sh /usr/local/bin/

# Add mailhog user/group with uid/gid 1000.
# This is a workaround for boot2docker issue #581, see
# https://github.com/boot2docker/boot2docker/issues/581
RUN adduser -D -u 1000 mailhog

USER mailhog

WORKDIR /home/mailhog

ENTRYPOINT ["MailHog-entrypoint.sh"]

# Expose the SMTP and HTTP ports:
EXPOSE 1025 8025
