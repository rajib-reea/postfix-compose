FROM debian:bookworm-slim

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    postfix libsasl2-modules mailutils dovecot-core dovecot-imapd openssl && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/spool/postfix/private && \
    chown postfix:postfix /var/spool/postfix/private && \
    chmod 710 /var/spool/postfix/private

COPY certs/server.crt /etc/ssl/certs/server.crt
COPY private/server.key /etc/ssl/private/server.key
RUN chmod 600 /etc/ssl/private/server.key

COPY postfix/main.cf /etc/postfix/main.cf
COPY postfix/master.cf /etc/postfix/master.cf
COPY dovecot/dovecot.conf /etc/dovecot/dovecot.conf

EXPOSE 25 587

CMD chown root:root /etc/postfix/main.cf /etc/postfix/master.cf && \
    chmod 644 /etc/postfix/main.cf /etc/postfix/master.cf && \
    service dovecot start && \
    postfix start-fg