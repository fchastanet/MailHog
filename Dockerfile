#
# MailHog Dockerfile
#

FROM golang:alpine

# Install MailHog:
RUN apk --no-cache add --virtual build-dependencies \
    git \
  && mkdir -p /root/gocode \
  && export GOPATH=/root/gocode \
  && git clone https://github.com/hdpe/MailHog.git /root/gocode/src/github.com/mailhog/MailHog \
  && cd /root/gocode/src/github.com/mailhog/MailHog \
  && go get ./... \
  && (cd /root/gocode/src/github.com/mailhog/MailHog-Server && git remote set-url origin https://github.com/hdpe/MailHog-Server.git && git fetch && git reset --hard origin/master) \
  && (cd /root/gocode/src/github.com/mailhog/data && git remote set-url origin https://github.com/hdpe/data.git && git fetch && git reset --hard origin/master) \
  && (cd /root/gocode/src/github.com/mailhog/http && git remote set-url origin https://github.com/hdpe/http.git && git fetch && git reset --hard origin/master) \
  && go install -i . \
  && mv /root/gocode/bin/MailHog /usr/local/bin \
  && rm -rf /root/gocode \
  && apk del --purge build-dependencies

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
