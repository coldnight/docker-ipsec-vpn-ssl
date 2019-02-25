# IPsec VPN Server on Docker with SSL Enabled

Docker image to run IPsec VPN server with SSL enabled.

Based on Debian 9 (Stretch) with [strongSwan 5.7.2](https://www.strongswan.org/)(IPsec VPN software).

## Prerequisites


- **Domain Name** You must have a domain name to obtain certificate.
- **Certificate** Of course a certificate is needed.

    You can got a free one from [Let's Encrypt](https://letsencrypt.org/). See also:

    - [certbot](https://certbot.eff.org/)
    - [acme.sh](https://github.com/Neilpang/acme.sh)

## Usage

### Prepare

First we need 3 files to map in docker container:

1. RSA private key that encoded in PEM format.

    Your key's conent should ends with `-----END RSA PRIVATE KEY-----`.
    Otherwise, if your key's content ends with `-----END PRIVATE KEY-----`, 
    you have to use `openssl` to convert by command like below:

    ```shell
    openssl rsa -in /path/to/privkey.pem -out /path/to/privkey.key
    ```

2. Cert file with chain and encoded in PEM format.(`fullchain.pem`)
3. Auth secret file:

    An example

    ```
    admin: XAUTH "P@ssw0rd"
    ```

### Starting server

Pull image:

```shell
docker pull grayking/ipsec-vpn-ssl
```

Start server:

```shell
docker run \
    -e DOMAIN_NAME=example.com \
    -e VPN_PSK=somerandomstringaspks \
    -v /path/to/example.com.key:/etc/ipsec.d/private/example_com.key   \ # RSA private key and replace `.` to `_` in domain name
    -v /path/to/example.com.crt:/etc/ipsec.d/certs/example_com.crt     \ # Full chain certificate file and replace `.` to `_` in domain name
    -v /path/to/xauth.secrets:/etc/ipsec-xauth.secrets  \
    -P \
    --privileged \
    --name ipsec-vpn-ssl \
    -d \
    grayking/ipsec-vpn-ssl
```

Restart server:

```shell
docker exec ipsec-vpn-ssl ipsec restart
```

-----

This project is largely inspired by [docker-ipsec-vpn-server](https://github.com/hwdsl2/docker-ipsec-vpn-server).
