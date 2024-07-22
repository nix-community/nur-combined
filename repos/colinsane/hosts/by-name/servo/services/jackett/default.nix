{ config, lib, pkgs, ... }:

let
  cfg = config.services.jackett;
in
{
  sane.persist.sys.byStore.plaintext = [
    # TODO: mode? we only need this to save Indexer creds ==> migrate to config?
    { user = "root"; group = "root"; path = "/var/lib/jackett"; method = "bind"; }
  ];
  services.jackett.enable = true;

  systemd.services.jackett.after = [ "wireguard-wg-ovpns.service" ];
  systemd.services.jackett.partOf = [ "wireguard-wg-ovpns.service" ];
  systemd.services.jackett.serviceConfig = {
    # run this behind the OVPN static VPN
    NetworkNamespacePath = "/run/netns/ovpns";
    ExecStartPre = [ "${lib.getExe pkgs.sane-scripts.ip-check} --no-upnp --expect ${config.sane.netns.ovpns.netnsPubIpv4}" ];  # abort if public IP is not as expected
    # patch in `--ListenPublic` so that it's reachable from the netns veth.
    # this also makes it reachable from the VPN pub address. oh well.
    ExecStart = lib.mkForce "${cfg.package}/bin/Jackett --ListenPublic --NoUpdates --DataFolder '${cfg.dataDir}'";
  };

  # jackett torrent search
  services.nginx.virtualHosts."jackett.uninsane.org" = {
    forceSSL = true;
    enableACME = true;
    # inherit kTLS;
    locations."/" = {
      proxyPass = "http://${config.sane.netns.ovpns.netnsVethIpv4}:9117";
      recommendedProxySettings = true;
    };
  };

  sane.dns.zones."uninsane.org".inet.CNAME."jackett" = "native";
}

