# postfix-compose
# postfix-relay
docker compose -f docker-relay.yaml up -d
telnet localhost 587
ehlo localhost
auth login

#postfix-ssl
# Make Postfix configs owned by root and not group/other writable
sudo chown root:root postfix/main.cf postfix/master.cf
sudo chmod 644 postfix/main.cf postfix/master.cf

# TLS private key should be root only
sudo chmod 600 private/server.key
sudo chmod 644 certs/server.crt
telnet localhost 587
ehlo localhost
auth login
