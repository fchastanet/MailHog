#!/bin/sh
[ -n "$MAILHOG_USER" ] && [ -n "$MAILHOG_PASSWORD" ] && {
    echo "$MAILHOG_USER:$(MailHog bcrypt "$MAILHOG_PASSWORD")" > /home/mailhog/mailhog.passwd
    AUTH_ARGS="-auth-file /home/mailhog/mailhog.passwd"
}

MailHog $AUTH_ARGS "$@"
