# import feeds with e.g.
# ```console
# $ nix build '.#nixpkgs.freshrss'
# $ sudo -u freshrss -g freshrss FRESHRSS_DATA_PATH=/var/lib/freshrss ./result/cli/import-for-user.php --user admin --filename /home/colin/.config/newsflashFeeds.opml
# ```
#
# export feeds with
# ```console
# $ sudo -u freshrss -g freshrss FRESHRSS_DATA_PATH=/var/lib/freshrss ./result/cli/export-opml-for-user.php --user admin
# ```

{ config, lib, pkgs, sane-lib, ... }:
{
  sops.secrets."freshrss_passwd" = {
    owner = config.users.users.freshrss.name;
    mode = "0400";
  };
  sane.persist.sys.plaintext = [
    { user = "freshrss"; group = "freshrss"; directory = "/var/lib/freshrss"; }
  ];

  services.freshrss.enable = true;
  services.freshrss.baseUrl = "https://rss.uninsane.org";
  services.freshrss.virtualHost = "rss.uninsane.org";
  services.freshrss.passwordFile = config.sops.secrets.freshrss_passwd.path;

  systemd.services.freshrss-import-feeds =
  let
    feeds = sane-lib.feeds;
    fresh = config.systemd.services.freshrss-config;
    all-feeds = config.sane.feeds;
    wanted-feeds = feeds.filterByFormat ["text" "image"] all-feeds;
    opml = pkgs.writeText "sane-freshrss.opml" (feeds.feedsToOpml wanted-feeds);
  in {
    inherit (fresh) wantedBy environment;
    serviceConfig = {
      inherit (fresh.serviceConfig) Type User Group StateDirectory WorkingDirectory
        # hardening options
        CapabilityBoundingSet DeviceAllow LockPersonality NoNewPrivileges PrivateDevices PrivateTmp PrivateUsers ProcSubset ProtectClock ProtectControlGroups ProtectHome ProtectHostname ProtectKernelLogs ProtectKernelModules ProtectKernelTunables ProtectProc ProtectSystem RemoveIPC RestrictNamespaces RestrictRealtime RestrictSUIDSGID SystemCallArchitectures SystemCallFilter UMask;
    };
    description = "import sane RSS feed list";
    after = [ "freshrss-config.service" ];
    script = ''
      # easiest way to preserve feeds: delete the user, recreate it, import feeds
      ${pkgs.freshrss}/cli/delete-user.php --user colin || true
      ${pkgs.freshrss}/cli/create-user.php --user colin --password "$(cat ${config.services.freshrss.passwordFile})" || true
      ${pkgs.freshrss}/cli/import-for-user.php --user colin --filename ${opml}
    '';
  };

  # the default ("*:0/5") is to run every 5 minutes.
  # `systemctl list-timers` to show
  systemd.services.freshrss-updater.startAt = lib.mkForce "*:3/30";

  services.nginx.virtualHosts."rss.uninsane.org" = {
    addSSL = true;
    enableACME = true;
    # inherit kTLS;
    # the routing is handled by services.freshrss.virtualHost
  };

  sane.services.trust-dns.zones."uninsane.org".inet.CNAME."rss" = "native";
}
