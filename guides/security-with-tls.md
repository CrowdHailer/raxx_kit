# Security with TLS (SSL)

## What is TLS (SSL)

- **TLS:** Transport Layer Security
- **SSL:** Secure Sockets Layer

Both protocols provide encryption and authentication to secure communication between a client and server.

TLS is the successor to SSL, however the terms are often used interchangable.
The last version of SSL (3.0) has demonstrated vulnerabilities and should not be used.

### "By Port" or "By Protocol"

A secure connection can be estabilshed in two distinct ways:

- **By Port:** Connect to a specific port that serves secure connections, e.g. 443 for https (secure web).
- **By Protocol:** First connect to an insecure port, second negotiate an upgrade.

*As far as I am aware either method of initiation is equally valid.
If anyone knows more on best practices please open a pull request.*

### Theres's more

"By Port" is commonly referred to as "SSL" event when it is an explicit connection to a TLS endpoint. "By Protocol" is commonly referred to as "TLS" even when it is an implicit upgrade to a SSL connection. A comprehensive overview is available at [SSL versus TLS – What’s the difference?](https://luxsci.com/blog/ssl-versus-tls-whats-the-difference.html).

## Certificates

To serve encrypted connections requires a certificate and certificate key.

### Generate a Certificate Signing Request(CSR)

```
openssl req -new -newkey rsa:2048 -nodes -keyout certificate_key.pem -out certificate_signing_request.pem
```

TODO walkthrough options

alternative filenames `domain.key` `domain.csr` `domain.crt`

### Sign a request
### Self signing certificate

To provide authentication about a server the certificate must be issed by a certificate signing authority.
A self signing certificate is one that was created by an untrusted/unknown authority.
These can be used to test the encrypted connection.
Examples here will be demonstrated with self signed certificates.
