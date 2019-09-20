#
# MailHog Dockerfile
#

# stage 1
FROM golang:alpine

# Install MailHog:
ARG MAILHOG_REPO_BASE_URL=https://github.com/fchastanet
ARG DATA_REPO_BASE_URL=https://github.com/hdpe
ARG HTTP_REPO_BASE_URL=https://github.com/hdpe
ARG MAILHOG_SERVER_REPO_BASE_URL=https://github.com/hdpe
ARG MAILHOG_UI_REPO_BASE_URL=https://github.com/simonbru
ARG MAILHOG_VENDOR_BASE_DIR=https://github.com/hdpe
ARG STORAGE_REPO_BASE_URL=https://github.com/hdpe
ARG SMTP_REPO_BASE_URL=https://github.com/hdpe
ARG VERSION=1.0.1

RUN true \
    && apk --no-cache add --virtual build-dependencies \
        git \
    && mkdir -p /root/gocode \
    && export GOPATH=/root/gocode \
    && git clone ${MAILHOG_REPO_BASE_URL}/MailHog.git /root/gocode/src/github.com/mailhog/MailHog \
    && cd /root/gocode/src/github.com/mailhog/MailHog \
    && rm -rf "${MAILHOG_VENDOR_BASE_DIR}/data" \
    && rm -rf "${MAILHOG_VENDOR_BASE_DIR}/http" \
    && rm -rf "${MAILHOG_VENDOR_BASE_DIR}/MailHog-Server" \
    && rm -rf "${MAILHOG_VENDOR_BASE_DIR}/MailHog-UI" \
    && rm -rf "${MAILHOG_VENDOR_BASE_DIR}/smtp" \
    && rm -rf "${MAILHOG_VENDOR_BASE_DIR}/storage" \
    && git clone "${DATA_REPO_BASE_URL}/data" "${MAILHOG_VENDOR_BASE_DIR}/data" \
    && git clone "${HTTP_REPO_BASE_URL}/http" "${MAILHOG_VENDOR_BASE_DIR}/http" \
    && git clone "${MAILHOG_SERVER_REPO_BASE_URL}/MailHog-Server" "${MAILHOG_VENDOR_BASE_DIR}/MailHog-Server" \
    && git clone "${MAILHOG_UI_REPO_BASE_URL}/MailHog-UI" "${MAILHOG_VENDOR_BASE_DIR}/MailHog-UI" \
    && git clone "${STORAGE_REPO_BASE_URL}/storage" "${MAILHOG_VENDOR_BASE_DIR}/storage" \
    && git clone "${SMTP_REPO_BASE_URL}/smtp" "${MAILHOG_VENDOR_BASE_DIR}/smtp" \
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
