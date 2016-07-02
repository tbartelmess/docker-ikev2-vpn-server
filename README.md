# IKEv2 VPN Server on Docker

If you need a simpler server that just uses a shared secret, have a look at [`gaomd/ikev2-vpn-server`](https://registry.hub.docker.com/u/gaomd/ikev2-vpn-server/)

## Settings

The container exposes a settings volume at `/vpn-settings` on startup a default configuration will be copied there
there is some configuration needed 

## Usage

### 1. Start the IKEv2 VPN Server

`docker run -d --name ikev2-vpn-server --restart=always -v /opt/vpn-settings:/vpn-settings --privileged -p 500:500/udp -p 4500:4500/udp tbartelmess/ikev2-vpn-server`

### 2. Generate the PKI Infrastructure for the server

***This is just simplistic example, for real world installations you probably don't want the CA key on the server,
and have users generate CSR's and not generate the keys for them***

#### Generate the CA
##### Create a key for the CA.

`docker run ikev2-vpn-server ipsec pki --gen > /opt/vpn-settings/ipsec.d/private/ca-key.der`

##### Generate the CA certificate

```
docker run ikev2-vpn-server ipsec pki 
--self
--in /vpn-settings/ipsec.d/caKey.der
--dn "C=CA, O=strongSwan, CN=strongSwan CA"
--ca > /opt/vpn-settings/ipsec.d/cacerts/ca-cert.der
```
#### Generate the Server certificate 

##### Generate the key for the server certificate

`docker run tbartelmess/ikev2-server ipsec pki --gen > /opt/vpn-settings/ipsec.d/private/server-key.der`

##### Extract the public key of the server key


`docker run ikev2-vpn-server ipsec pki --pub --in /vpn-settings/ipsec.d/private/server-key.der  > /opt/vpn-settings/ipsec.d/pubkeys/server-pubkey.der`

##### Create the server cert

Replace `SERVER_ADDRESS` with the FQDN/IP of your server. If you have multiple addresses you add more SAN entries `--san OTHER_SERVER_NAME`

```
docker run ikev2-vpn-server ipsec pki --issue \
--in /opt/vpn-settings/ipsec.d/pubkeys/server-pubkey.der \
--cacert /opt/vpn-settings/ipsec.d/cacerts/ca-cert.der\
--cakey caKey.der \
--san SERVER_ADDRESS
--dn "C=CH, O=strongSwan, CN=SERVER_ADDRESS" > /opt/vpn-settings/ipsec.d/server-cert.der
```

#### Setup Client a Client certificate

Do this for every user of the VPN.

#### Create a key for a client

`docker run ikev2-vpn-server ipsec pki --gen > /opt/vpn-settings/ipsec.d/private/my-client-key.der`

#### Extract the public key

`docker run ikev2-vpn-server ipsec pki --pub --in /vpn-settings/ipsec.d/private/my-client-key.der  > /opt/vpn-settings/ipsec.d/pubkeys/my-client-pubkey.der`

##### Create the client cert

Replace `USERNAME` with the username/email of the user. If you have multiple addresses you add more SAN entries `--san OTHER_USERNAME`. For iOS/OSX you need at least one SAN. It works best with email addresses

```
docker run ikev2-vpn-server ipsec pki --issue \
--in /vpn-settings/ipsec.d/pubkeys/my-client-pubkey.der \
--cacert /vpn-settings/ipsec.d/cacerts/ca-cert.der \
--cakey /vpn-settings/ipsec.d/private/ca-key.der \
--san thomas@bartelmess.io \
--dn "C=CH, O=strongSwan, CN=thomas@bartelmess.io" > /opt/vpn-settings/ipsec.d/client-cert.der
```

### Restart the server

`docker restart -t 1 ikev2-vpn-server`

## License

Copyright (c) 2016 Thomas Bartelmess, This software is licensed under the [MIT License](LICENSE).

Based on https://www.github.com/gaomd/docker-ikev2-vpn-server/

Copyright (c) 2016 Mengdi Gao, This software is licensed under the [MIT License](LICENSE).

---

* IKEv2 protocol requires iOS 8 or later, Mac OS X 10.11 El Capitan is supported as well.

* iOS and OS X/macOS are really picky about having a SAN in the client certificates.
