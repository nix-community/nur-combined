# Softphones reach pbxvm on prophecy's public address. Keep in step with
# vacu.pbx.softphoneTlsPort and vacu.pbx.rtpPortRange on pbxvm.
{ config, ... }:
let
  pbx = config.vacu.qemuVMs.pbxvm.v4Address;
  public = config.vacu.network.ips.doofStatic4;
in
{
  # Matched on destination rather than interface, so LAN clients using the
  # public name hairpin here too.
  networking.firewall.extraCommands = ''
    iptables -t nat -N pbx-dnat 2>/dev/null || true
    iptables -t nat -F pbx-dnat
    iptables -t nat -A pbx-dnat -d ${public} -p tcp --dport 5061 -j DNAT --to-destination ${pbx}
    iptables -t nat -A pbx-dnat -d ${public} -p udp --dport 10000:10999 -j DNAT --to-destination ${pbx}
    iptables -t nat -C PREROUTING -j pbx-dnat 2>/dev/null \
      || iptables -t nat -A PREROUTING -j pbx-dnat
  '';
  networking.firewall.extraStopCommands = ''
    iptables -t nat -D PREROUTING -j pbx-dnat 2>/dev/null || true
    iptables -t nat -F pbx-dnat 2>/dev/null || true
    iptables -t nat -X pbx-dnat 2>/dev/null || true
  '';

  # ACME HTTP-01 for pbx.shelvacu.com; pbxvm answers it.
  services.caddy.virtualHosts."http://pbx.shelvacu.com" = {
    vacu.hsts = false;
    extraConfig = ''
      bind ${config.vacu.sniFrontend.httpBind}
      handle /.well-known/acme-challenge/* {
        reverse_proxy ${pbx}:80
      }
      respond 404
    '';
  };
}
