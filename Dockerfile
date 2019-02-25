FROM debian:stretch
MAINTAINER Gray King <grayking.w@gmail.com>

WORKDIR /usr/src

RUN apt update \
    && apt install -y build-essential libgmp10 libgmp3-dev libssl-dev \
        pkg-config libpcsclite-dev libpam0g-dev curl kmod iptables

ENV STRONG_SWAN_VER 5.7.2

RUN curl -O https://download.strongswan.org/strongswan-${STRONG_SWAN_VER}.tar.bz2 \
    && tar -jxf strongswan-${STRONG_SWAN_VER}.tar.bz2 \
    && cd strongswan-${STRONG_SWAN_VER} \
    && ./configure --prefix=/usr --sysconfdir=/etc --enable-eap-mschapv2 --enable-eap-identity --enable-eap-peap --enable-openssl --enable-md4 \
    && make && make install

COPY run.sh /usr/bin/run-ipsec.sh
RUN chmod +x /usr/bin/run-ipsec.sh
VOLUME ["/lib/modules"]

EXPOSE 500/udp 4500/udp

CMD ["/usr/bin/run-ipsec.sh"]
