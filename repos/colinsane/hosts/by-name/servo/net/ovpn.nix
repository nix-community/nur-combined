{ config, ... }:
{
  sane.ovpn.addrV4 = "172.23.174.114";
  # sane.ovpn.addrV6 = "fd00:0000:1337:cafe:1111:1111:8df3:14b0";

  # OVPN CONFIG (https://www.ovpn.com):
  # DOCS: https://nixos.wiki/wiki/WireGuard
  sane.netns.ovpns = {
    veth.initns.ipv4 = "10.0.1.5";
    veth.netns.ipv4 = "10.0.1.6";
    routeTable = 11;
    dns.ipv4 = "46.227.67.134";  #< DNS requests inside the namespace are forwarded here
    wg.port = 51822;
    wg.privateKeyFile = config.sops.secrets.wg_ovpns_privkey.path;
    wg.address.ipv4 = "185.157.162.178";
    wg.peer.publicKey = "SkkEZDCBde22KTs/Hc7FWvDBfdOCQA4YtBEuC3n5KGs=";
    wg.peer.endpoint = "vpn36.prd.amsterdam.ovpn.com:9930";
    # wg.peer.endpoint = "185.157.162.10:9930";
  };
}
