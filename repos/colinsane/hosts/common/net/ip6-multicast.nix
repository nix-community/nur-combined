{ lib, pkgs, ... }:
{
  networking.firewall.extraCommands = let
    ipset = lib.getExe pkgs.ipset;
    ip6tables = lib.getExe' pkgs.iptables "ip6tables";
  in ''
    # allow IPv6 multicast packets to loop back to the sender.
    # XXX(2026-07-13): this is required for my work.
    # inspired from: <https://serverfault.com/a/911286>
    # ipset -! means "don't fail if set already exists"
    ${ipset} create -! mcast6loop hash:ip,port timeout 10 family inet6
    ${ip6tables} -A OUTPUT -d ff02::/16 -p udp -j SET --add-set mcast6loop dst,dst --exist
    ${ip6tables} -A INPUT -p udp -m set --match-set mcast6loop dst,dst -j ACCEPT
  '';
}
