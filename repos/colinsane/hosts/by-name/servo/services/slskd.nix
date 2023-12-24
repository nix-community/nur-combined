# Soulseek daemon (p2p file sharing with an emphasis on Music)
# docs: <https://github.com/slskd/slskd/blob/master/docs/config.md>
#
# config precedence (higher precedence overrules lower precedence):
# - Default Values < Environment Variables < YAML Configuraiton File < Command Line Arguments
{ config, lib, ... }:
{
  sane.persist.sys.byStore.plaintext = [
    { user = "slskd"; group = "slskd"; path = "/var/lib/slskd"; }
  ];
  sops.secrets."slskd_env" = {
    owner = config.users.users.slskd.name;
    mode = "0400";
  };

  users.users.slskd.extraGroups = [ "media" ];

  sane.ports.ports."50000" = {
    protocol = [ "tcp" ];
    # not visible to WAN: i run this in a separate netns
    visibleTo.ovpn = true;
    description = "colin-soulseek";
  };

  sane.dns.zones."uninsane.org".inet.CNAME."soulseek" = "native";

  services.nginx.virtualHosts."soulseek.uninsane.org" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://10.0.1.6:5001";
      proxyWebsockets = true;
    };
  };

  services.slskd.enable = true;
  # env file, for auth (SLSKD_SLSK_PASSWORD, SLSKD_SLSK_USERNAME)
  services.slskd.environmentFile = config.sops.secrets.slskd_env.path;
  services.slskd.settings = {
    soulseek.diagnostic_level = "Debug";  # one of "None"|"Warning"|"Info"|"Debug"
    shares.directories = [
      # folders to share
      # syntax: <https://github.com/slskd/slskd/blob/master/docs/config.md#directories>
      # [Alias]/path/on/disk
      # NOTE: Music library is quick to scan; videos take a solid 10min to scan.
      # TODO: re-enable the other libraries
      # "[Audioooks]/var/lib/uninsane/media/Books/Audiobooks"
      # "[Books]/var/lib/uninsane/media/Books/Books"
      # "[Manga]/var/lib/uninsane/media/Books/Visual"
      # "[games]/var/lib/uninsane/media/games"
      "[Music]/var/lib/uninsane/media/Music"
      # "[Film]/var/lib/uninsane/media/Videos/Film"
      # "[Shows]/var/lib/uninsane/media/Videos/Shows"
    ];
    # directories.downloads = "..." # TODO
    # directories.incomplete = "..." # TODO
    # what unit is this? kbps??
    global.upload.speed_limit = 32000;
    web.logging = true;
    # debug = true;
    flags.no_logo = true;  # don't show logo at start
    # flags.volatile = true;  # store searches and active transfers in RAM (completed transfers still go to disk). rec for btrfs/zfs
  };

  systemd.services.slskd = {
    serviceConfig = {
      # run this behind the OVPN static VPN
      NetworkNamespacePath = "/run/netns/ovpns";
      Restart = lib.mkForce "always";  # exits "success" when it fails to connect to soulseek server
      RestartSec = "60s";
      Group = "media";
    };
  };
}
