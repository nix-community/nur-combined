{ lib, pkgs, ... }:

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
    ExecStartPre = [ "${lib.getExe pkgs.sane-scripts.ip-check} --no-upnp --expect 185.157.162.178" ];  # abort if public IP is not as expected

    # patch jackett to listen on the public interfaces
    # ExecStart = lib.mkForce "${pkgs.jackett}/bin/Jackett --NoUpdates --DataFolder /var/lib/jackett/.config/Jackett --ListenPublic";
  };

  # jackett torrent search
  services.nginx.virtualHosts."jackett.uninsane.org" = {
    forceSSL = true;
    enableACME = true;
    # inherit kTLS;
    locations."/" = {
      # proxyPass = "http://ovpns.uninsane.org:9117";
      proxyPass = "http://10.0.1.6:9117";
      recommendedProxySettings = true;
    };
  };

  sane.dns.zones."uninsane.org".inet.CNAME."jackett" = "native";
}

