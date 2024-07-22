{ config, lib, pkgs, ... }:

{
  sane.persist.sys.byStore.plaintext = [
    # TODO: mode? we only need this to save Indexer creds ==> migrate to config?
    { user = "root"; group = "root"; path = "/var/lib/jackett"; method = "bind"; }
  ];
  services.jackett.enable = true;
  services.jackett.package = pkgs.jackett.overrideAttrs (upstream: {
    patches = (upstream.patches or []) ++ [
      # bind to an IP address which is usable behind a netns.
      # jackett doesn't allow customization of the bind address: this will probably always be here.
      ./01-fix-bind-host.patch
    ];
  });

  systemd.services.jackett.after = [ "wireguard-wg-ovpns.service" ];
  systemd.services.jackett.partOf = [ "wireguard-wg-ovpns.service" ];
  systemd.services.jackett.serviceConfig = {
    # run this behind the OVPN static VPN
    NetworkNamespacePath = "/run/netns/ovpns";
    ExecStartPre = [ "${lib.getExe pkgs.sane-scripts.ip-check} --no-upnp --expect ${config.sane.netns.ovpns.netnsPubIpv4}" ];  # abort if public IP is not as expected
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

