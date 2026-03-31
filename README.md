# Certificate Creation
````
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout private/server.key -out certs/server.crt \
  -days 365 -subj "/CN=localhost"
````
# Give permission

# Make Postfix configs owned by root and not group/other writable
````
sudo chown root:root postfix/main.cf postfix/master.cf
sudo chmod 644 postfix/main.cf postfix/master.cf
````

# TLS private key should be root only
````
sudo chmod 600 private/server.key
sudo chmod 644 certs/server.crt
````

# Run docker compose

````
A. Relay Run:
docker compose -f docker-relay.yaml up --build
docker compose -f docker-relay.yaml down

B. TLS Run:
docker compose -f docker-ssl.yaml up --build
docker compose -f docker-ssl.yaml down
````

# Troubleshoot Issue

````
docker run -it --rm \
  -v $(pwd)/certs:/etc/ssl/certs \
  -v $(pwd)/private:/etc/ssl/private \
  -v $(pwd)/postfix/main.cf:/etc/postfix/main.cf \
  -v $(pwd)/postfix/master.cf:/etc/postfix/master.cf \
  email-testing-postfix /bin/bash

on container terminal issue:

postfix check
postfix start
````
# Postfix & Dovecot Dockerized Mail Server

A lightweight Postfix and Dovecot setup running in Docker, configured for SMTP Authentication (SASL) and TLS encryption. This setup is ideal for local development and testing mail flows.

## 🚀 Quick Start

### 1. Launch the Container
Start the services using the provided Docker Compose file:
```bash
docker compose -f docker-ssl.yaml up -d --build
2. Verify the Services
Check the logs to ensure Postfix and Dovecot started correctly:

Bash
docker logs -f postfix
🔒 Permissions Fixes
Postfix is strict about file permissions. If you encounter "fatal" or "warning" errors regarding configuration ownership, apply the following:

🛠 Testing the Connection
1. Basic SMTP Connectivity (Telnet)
Verify that the server is listening and advertising the correct capabilities:

Bash
telnet localhost 587
Inside the telnet session, run:

Plaintext
EHLO localhost
Expected output: Look for 250-STARTTLS and 250-AUTH PLAIN LOGIN.

2. Manual Login Test
To test authentication manually, use the AUTH LOGIN command (Credentials must be Base64 encoded):

Bash
# In telnet session:
AUTH LOGIN

# Server responds with 334 VXNlcm5hbWU6 (Username:)
# Type: dXNlcg== (Base64 for 'user')

# Server responds with 334 UGFzc3dvcmQ6 (Password:)
# Type: cGFzc3dvcmQ= (Base64 for 'password')

# Result: 235 2.7.0 Authentication successful
3. Testing Encryption (OpenSSL)
To test the full SSL/TLS handshake:

Bash
openssl s_client -connect localhost:587 -starttls smtp
⚙️ Configuration Details
SMTP Port: 587 (Submission) / 25

Authentication: Dovecot SASL

TLS: Enabled (Self-signed)

Default Credentials: * User: user

Password: password


### Pro-Tip:
Since you are a **software developer** often working with **Spring Boot** and **distributed systems**, you can now easily integrate this into your `application.properties`:

```properties
spring.mail.host=localhost
spring.mail.port=587
spring.mail.username=user
spring.mail.password=password
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
````
# OpenSSL Flow

````
openssl s_client -connect localhost:587 -starttls smtp
CONNECTED(00000003)
Can't use SSL_get_servername
depth=0 CN = localhost
verify error:num=18:self-signed certificate
verify return:1
depth=0 CN = localhost
verify return:1
---
Certificate chain
 0 s:CN = localhost
   i:CN = localhost
   a:PKEY: rsaEncryption, 2048 (bit); sigalg: RSA-SHA256
   v:NotBefore: Mar 31 09:36:31 2026 GMT; NotAfter: Mar 31 09:36:31 2027 GMT
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIDCTCCAfGgAwIBAgIUeBXYhwVE1QFfUvpuH9QsW8bBQpkwDQYJKoZIhvcNAQEL
BQAwFDESMBAGA1UEAwwJbG9jYWxob3N0MB4XDTI2MDMzMTA5MzYzMVoXDTI3MDMz
MTA5MzYzMVowFDESMBAGA1UEAwwJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEF
AAOCAQ8AMIIBCgKCAQEA6/JPpd981U7KpxODitR36w/w/w8W1ukKBiSRMA6oefEi
45d2v3vwMIdEkmJTjgmbg46GvZebf+ocrl+dMcJ7Prr9RhtULxVUNMngkto1FBzH
ViSewAd7bviAP21z5R85SLmG822rGw3bGkOt/Oq13SU9Phr7yeL9wDznDvTg/41s
fQ8TIoPmcUjfcYOc4YtwGD6MSs0ERT9Nk5eClrVwQr6cH/IycwcDRy6dNcn3SHWT
WVTOW8DiZJ7jiLHh7mZxcaBaR5ivu5CaaxKHX0qcFbBpO1QnxfTjtnk8pe+8XueU
nz2AG24T9kkdn1vczv6TQ0Mq8215kKfITawPDkBN9wIDAQABo1MwUTAdBgNVHQ4E
FgQUJulv8KqVKSLc8Pil3GIEYIRKFtgwHwYDVR0jBBgwFoAUJulv8KqVKSLc8Pil
3GIEYIRKFtgwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAyvdk
D/w9ZxmXYh636yXfkSYmG/51q+o+YKnVMaGINbuTPNP2FVX1Shrk9/IKdLCnY6Fl
aUhj/Z8szD5NnuxqhkYFmQoHGhllRPKqV1HjaaSr0nFpuIRzKdCpL2ZwVly3qyyO
vPSmSxdKnP1ZQ8iLnxWZ0Nc/9UC7xNHx9nXz0Lwzb6mehPPrP3CltAvBm3PAXNib
BSh7mMpJsHvINV2OemCH67iHkQM+AucfvmHcfH8+2RIlMTGc3w+IJQQemsZOhfGa
9J/57HrPvZrSk4LVKkoS8LeuWk98mrQ0paoY9+IIT7GbZUCOXEVv1h+PuDPg/oWR
DgfJLzPotLGZyp1+5g==
-----END CERTIFICATE-----
subject=CN = localhost
issuer=CN = localhost
---
No client certificate CA names sent
Peer signing digest: SHA256
Peer signature type: RSA-PSS
Server Temp Key: X25519, 253 bits
---
SSL handshake has read 1588 bytes and written 406 bytes
Verification error: self-signed certificate
---
New, TLSv1.3, Cipher is TLS_AES_256_GCM_SHA384
Server public key is 2048 bit
Secure Renegotiation IS NOT supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
Early data was not sent
Verify return code: 18 (self-signed certificate)
---
250 CHUNKING
---
Post-Handshake New Session Ticket arrived:
SSL-Session:
    Protocol  : TLSv1.3
    Cipher    : TLS_AES_256_GCM_SHA384
    Session-ID: 8AE06EA5C94FB601E91EEDA66DADFA3871558F577A60D6A121DD4EB07811349A
    Session-ID-ctx:
    Resumption PSK: 6A2E7C8339CC84824925C8F0629F19E53EB1E039338515580DC618DD400C976420FAEFA0823885F4CF25011710A16509
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 7200 (seconds)
    TLS session ticket:
    0000 - 8c 4d 37 fd 3d d8 4d 0e-23 4b 05 c6 d2 7b 6d 1b   .M7.=.M.#K...{m.
    0010 - 0e 5a 77 ae 2b 10 3f 66-e7 71 1f fe 58 f0 ca 5d   .Zw.+.?f.q..X..]
    0020 - c1 16 55 36 eb 50 cc bd-e1 f4 7e c0 b9 20 86 76   ..U6.P....~.. .v
    0030 - cf 0c 2a 48 52 55 eb ba-72 13 6e ba b7 51 25 f1   ..*HRU..r.n..Q%.
    0040 - 32 52 c8 73 5a d0 77 a7-1d ef 6c d9 ed a4 cc 4f   2R.sZ.w...l....O
    0050 - ff c6 69 87 6d 04 b6 80-39 44 cb 4c 9f 50 b6 86   ..i.m...9D.L.P..
    0060 - 2e fc 70 94 08 5c 91 e2-18 43 34 74 04 fe 39 1c   ..p..\...C4t..9.
    0070 - 4e 4c bc 93 c8 42 05 cb-90 a1 a8 f8 d9 e2 aa c1   NL...B..........
    0080 - 17 d7 d9 ad fb 33 84 74-38 c3 74 e7 97 35 72 84   .....3.t8.t..5r.
    0090 - d8 c8 9b dd cf a9 ab 24-c4 09 ef e7 6c 0f ec 5e   .......$....l..^
    00a0 - e3 71 99 98 d9 27 de bd-05 88 36 a9 4b d8 52 69   .q...'....6.K.Ri
    00b0 - 29 da 98 e6 ba 8d 5f 4a-05 cd 47 61 99 06 41 78   )....._J..Ga..Ax
    00c0 - 24 9d 62 07 93 d8 df 6b-ec e5 71 84 6e 3c f7 a1   $.b....k..q.n<..

    Start Time: 1774960831
    Timeout   : 7200 (sec)
    Verify return code: 18 (self-signed certificate)
    Extended master secret: no
    Max Early Data: 0
---
read R BLOCK
````

# Install swaks

````
sudo apt update
sudo apt install swaks -y
swaks --version
````
# swaks flow
````
swaks \
  --to user@example.com \
  --server localhost:587 \
  --auth LOGIN \
  --auth-user user \
  --auth-password password \
  --tls \
  -p
Port: 587
=== Trying localhost:587...
=== Connected to localhost.
<-  220 mail.localhost ESMTP Postfix
 -> EHLO DESKTOP-QDHJQOO.localdomain
<-  250-mail.localhost
<-  250-PIPELINING
<-  250-SIZE 10240000
<-  250-VRFY
<-  250-ETRN
<-  250-STARTTLS
<-  250-AUTH PLAIN LOGIN
<-  250-ENHANCEDSTATUSCODES
<-  250-8BITMIME
<-  250-DSN
<-  250-SMTPUTF8
<-  250 CHUNKING
 -> STARTTLS
<-  220 2.0.0 Ready to start TLS
=== TLS started with cipher TLSv1.3:TLS_AES_256_GCM_SHA384:256
=== TLS client certificate not requested and not sent
=== TLS no client certificate set
=== TLS peer[0]   subject=[/CN=localhost]
===               commonName=[localhost], subjectAltName=[] notAfter=[2027-03-31T09:36:31Z]
=== TLS peer certificate failed CA verification (self-signed certificate), passed host verification (using host localhost to verify)
 ~> EHLO DESKTOP-QDHJQOO.localdomain
<~  250-mail.localhost
<~  250-PIPELINING
<~  250-SIZE 10240000
<~  250-VRFY
<~  250-ETRN
<~  250-AUTH PLAIN LOGIN
<~  250-ENHANCEDSTATUSCODES
<~  250-8BITMIME
<~  250-DSN
<~  250-SMTPUTF8
<~  250 CHUNKING
 ~> AUTH LOGIN
<~  334 VXNlcm5hbWU6
 ~> dXNlcg==
<~  334 UGFzc3dvcmQ6
 ~> cGFzc3dvcmQ=
<~  235 2.7.0 Authentication successful
 ~> MAIL FROM:<rajib@DESKTOP-QDHJQOO.localdomain>
<~  250 2.1.0 Ok
 ~> RCPT TO:<user@example.com>
<~  250 2.1.5 Ok
 ~> DATA
<~  354 End data with <CR><LF>.<CR><LF>
 ~> Date: Tue, 31 Mar 2026 18:35:05 +0600
 ~> To: user@example.com
 ~> From: rajib@DESKTOP-QDHJQOO.localdomain
 ~> Subject: test Tue, 31 Mar 2026 18:35:05 +0600
 ~> Message-Id: <20260331183505.011504@DESKTOP-QDHJQOO.localdomain>
 ~> X-Mailer: swaks v20240103.0 jetmore.org/john/code/swaks/
 ~>
 ~> This is a test mailing
 ~>
 ~>
 ~> .
<~  250 2.0.0 Ok: queued as BDD539ABFC
 ~> QUIT
<~  221 2.0.0 Bye
=== Connection closed with remote host.
````
