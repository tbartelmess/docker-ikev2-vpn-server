FROM ubuntu:16.04

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install strongswan iptables uuid-runtime ndppd openssl curl iputils-ping strongswan-plugin-eap-mschapv2 strongswan-plugin-pubkey

ADD ./vpn-settings /vpn-settings-defaults
ADD ./bin/* /usr/bin/

VOLUME /vpn-settings

# http://blogs.technet.com/b/rrasblog/archive/2006/06/14/which-ports-to-unblock-for-vpn-traffic-to-pass-through.aspx
EXPOSE 500/udp 4500/udp

CMD /usr/bin/start-vpn
