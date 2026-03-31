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

Postfix Configurations
Ensure the config files are owned by root and not group/world writable:

Bash
sudo chown root:root postfix/main.cf postfix/master.cf
sudo chmod 644 postfix/main.cf postfix/master.cf
TLS Certificates & Keys
The private key must be restricted to root only:

Bash
sudo chmod 600 private/server.key
sudo chmod 644 certs/server.crt
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
