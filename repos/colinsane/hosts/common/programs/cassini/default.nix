{ config, lib, pkgs, ...}:
let
  cfg = config.sane.programs.cassini;
in
{
  sane.programs.cassini = {
    sandbox.method = null;  #< TODO: sandbox
  };

  # inspired by SSDP firewall code.
  # Elegoo printers use their own SSDP-like discovery method, but on port 3000 instead of 1900 and 255.255.255.255 instead of 239.255.255.250:
  # 1. i send a broadcast packet to 255.255.255.255 port 3000;
  # 2. printers respond with a packet that originates from their port 3000, addressed to whichever port i sent from.
  #
  # TODO: can i generalize the SSDP rule from <hosts/common/net/upnp.nix> to be generic over port?
  networking.firewall.extraCommands = with pkgs; lib.mkIf cfg.enabled ''
    # originally for SSDP: <https://serverfault.com/a/911286>
    # ipset -! means "don't fail if set already exists"
    ${ipset}/bin/ipset create -! upnp hash:ip,port timeout 10
    ${iptables}/bin/iptables -A OUTPUT -d 255.255.255.255/32 -p udp -m udp --dport 3000 -j SET --add-set upnp src,src --exist
    ${iptables}/bin/iptables -A INPUT -p udp -m set --match-set upnp dst,dst -j ACCEPT

    # IPv6 ruleset. ff02::/16 means *any* link-local multicast group (so this is probably more broad than it needs to be)
    ${ipset}/bin/ipset create -! upnp6 hash:ip,port timeout 10 family inet6
    ${iptables}/bin/ip6tables -A OUTPUT -d ff02::/16 -p udp -m udp --dport 3000 -j SET --add-set upnp6 src,src --exist
    ${iptables}/bin/ip6tables -A INPUT -p udp -m set --match-set upnp6 dst,dst -j ACCEPT
  '';
}
