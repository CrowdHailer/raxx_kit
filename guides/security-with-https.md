# Security with HTTPS

*If familiar with generating certificates just to [server setup](#server-setup)*

## What is TLS (SSL)

- **TLS:** Transport Layer Security
- **SSL:** Secure Sockets Layer

Both protocols provide encryption and authentication to secure communication between a client and server.

TLS is the successor to SSL, however the terms are often used interchangable.
The last version of SSL (3.0) has demonstrated vulnerabilities and should not be used.

#### "By Port" or "By Protocol"

A secure connection can be estabilshed in two distinct ways:

- **By Port:** Connect to a specific port that serves secure connections, e.g. 443 for https (secure web).
- **By Protocol:** First connect to an insecure port, second negotiate an upgrade.

*As far as I am aware either method of initiation is equally valid.
If anyone knows more on best practices please open a pull request.*

#### Theres's more

"By Port" is commonly referred to as "SSL" event when it is an explicit connection to a TLS endpoint. "By Protocol" is commonly referred to as "TLS" even when it is an implicit upgrade to a SSL connection. A comprehensive overview is available at [SSL versus TLS – What’s the difference?](https://luxsci.com/blog/ssl-versus-tls-whats-the-difference.html).

## Generating credentials

To serve encrypted connections a server requires:

- A certificate for the domain: `mydomain/certificate.pem`
- The private key associated with the certificate: `mydomain/certificate_key.pem`

#### Generating a Key

A new key can be created using `openssl`, which is already present on most linux machines.

```
$ openssl genrsa -out certificate_key.pem
```

#### Getting a signed Certificate

Producing a certificate signing request (CSR) is the first step to getting a certificate.
This is also done with `openssl` and you will be guided to provide details about your certificate.

```
$ openssl req -new -key certificate_key.pem -out certificate_signing_request.pem
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:UK
State or Province Name (full name) [Some-State]:London
Locality Name (eg, city) []:London
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Workshop 14 Limited
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:example.com
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

For a client to authenticate a server the CSR must be signed by a certificate authority (CA) it recognises.
In development we can skip the CA by signing the certificate ourselves.

```
$ openssl x509 -req -days 365 \
  -in certificate_signing_request.pem \
  -signkey certificate_key.pem \
  -out certificate.pem
```

## Server setup

### Ace

To start a secure server with Ace use `Ace.HTTPS` in place of `Ace.HTTP`.
Both modules provide the same interface with a few extra options required to start HTTPS.

```elixir
certificate_path = Application.app_dir(:my_app, "priv/example.com/certificate.pem")
certificate_key_path = Application.app_dir(:my_app, "priv/example.com/certificate_key.pem")

Ace.HTTP2.Service.start_link({MyApp, :noconfig}, [
  certfile: certificate_path,
  keyfile: certificate_key_path,
  port: 8443
])
```

The key files must be in a projects `priv` directory if using releases.
This is a convention inherited from erlang.
The process of generating releases assumes this convention is followed

TODO link to https example in WaterCooler.

## Further topics

- Security headers to ensure a user uses HTTPS, see [Plug.SSL](https://github.com/elixir-lang/plug/blob/master/lib/plug/ssl.ex)
- Automatically creating a certificate using the Acme (Automatic Certificate Management Environment) protocol and lets encryp.
- What is a cacerts file? http://www.phoenixframework.org/docs/configuration-for-ssl
