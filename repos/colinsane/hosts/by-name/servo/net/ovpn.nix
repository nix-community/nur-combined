{ config, ... }:
{
  sane.ovpn.addrV4 = "172.23.174.114";  #< this applies to the dynamic VPNs -- NOT the static VPN
  # sane.ovpn.addrV6 = "fd00:0000:1337:cafe:1111:1111:8df3:14b0";

  # OVPN CONFIG (https://www.ovpn.com):
  # DOCS: https://nixos.wiki/wiki/WireGuard
  sane.netns.ovpns = {
    veth.initns.ipv4 = "10.0.1.5";
    veth.netns.ipv4 = "10.0.1.6";
    routeTable = 11;
    dns.ipv4 = "46.227.67.134";  #< DNS requests inside the namespace are forwarded here
    # wg.port = 51822;
    wg.privateKeyFile = config.sops.secrets.wg_ovpns_privkey.path;
    wg.address.ipv4 = "146.70.100.165";  #< IP address for my end of the VPN tunnel. for OVPN public IPv4, this is also the public IP address.
    wg.peer.publicKey = "xc9p/lf2uLg6IGDh54E0Pbc6WI/J9caaByhwD4Uiu0Q=";  #< pubkey by which i can authenticate OVPN, varies per OVPN endpoint
    wg.peer.endpoint = "vpn31.prd.losangeles.ovpn.com:9930";
    # wg.peer.endpoint = "45.83.89.131:9930";
  };
}
