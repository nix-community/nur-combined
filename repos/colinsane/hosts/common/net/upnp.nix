{ pkgs, ... }:
{
  networking.firewall.allowedUDPPorts = [
    # to receive UPnP advertisements. required by sane-ip-check.
    # N.B. sane-ip-check isn't query/response based. it needs to receive on port 1900 -- not receive responses FROM port 1900.
    1900
  ];

  networking.firewall.extraCommands = with pkgs; ''
    # after an outgoing SSDP query to the multicast address (dest port=1900, src port=any),
    # open FW for incoming responses (i.e. accept any packet, so long as it's sent to the port we sent from).
    # necessary for anything DLNA, especially go2tv
    # source: <https://serverfault.com/a/911286>
    # context: <https://github.com/alexballas/go2tv/issues/72>

    # ipset -! means "don't fail if set already exists"
    ${ipset}/bin/ipset create -! upnp hash:ip,port timeout 10
    ${iptables}/bin/iptables -A OUTPUT -d 239.255.255.250/32 -p udp -m udp --dport 1900 -j SET --add-set upnp src,src --exist
    ${iptables}/bin/iptables -A INPUT -p udp -m set --match-set upnp dst,dst -j ACCEPT

    # IPv6 ruleset. ff02::/16 means *any* link-local multicast group (so this is probably more broad than it needs to be)
    ${ipset}/bin/ipset create -! upnp6 hash:ip,port timeout 10 family inet6
    ${iptables}/bin/ip6tables -A OUTPUT -d ff02::/16 -p udp -m udp --dport 1900 -j SET --add-set upnp6 src,src --exist
    ${iptables}/bin/ip6tables -A INPUT -p udp -m set --match-set upnp6 dst,dst -j ACCEPT
  '';
}
