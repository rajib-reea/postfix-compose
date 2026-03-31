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

# Install swaks

````
sudo apt update
sudo apt install swaks -y
swaks --version
````
