{ pkgs, ... }:
{
  networking.firewall.allowedUDPPorts = [
    # to receive UPnP advertisements. required by sane-ip-check.
    # N.B. sane-ip-check isn't query/response based. it needs to receive on port 1900 -- not receive responses FROM port 1900.
    1900
  ];

  networking.firewall.extraCommands = with pkgs; ''
    # after an outgoing SSDP query to the multicast address, open FW for incoming responses.
    # necessary for anything DLNA, especially go2tv
    # source: <https://serverfault.com/a/911286>
    # context: <https://github.com/alexballas/go2tv/issues/72>

    # ipset -! means "don't fail if set already exists"
    ${ipset}/bin/ipset create -! upnp hash:ip,port timeout 10
    ${iptables}/bin/iptables -A OUTPUT -d 239.255.255.250/32 -p udp -m udp --dport 1900 -j SET --add-set upnp src,src --exist
    ${iptables}/bin/iptables -A INPUT -p udp -m set --match-set upnp dst,dst -j ACCEPT
  '';
}
