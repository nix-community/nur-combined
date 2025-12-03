# Soulseek daemon (p2p file sharing with an emphasis on Music)
# docs: <https://github.com/slskd/slskd/blob/master/docs/config.md>
#
# config precedence (higher precedence overrules lower precedence):
# - Default Values < Environment Variables < YAML Configuraiton File < Command Line Arguments
#
# debugging:
# - soulseek is just *flaky*. if you see e.g. DNS errors, even though you can't replicate them via `dig` or `getent ahostsv4`, just give it 10 minutes to work out:
#   - "Soulseek.AddressException: Failed to resolve address 'vps.slsknet.org': Resource temporarily unavailable"
{ config, lib, pkgs, ... }:

{
  sane.persist.sys.byStore.ephemeral = [
    # {data,downloads,incomplete,logs}: contains logs, search history, and downloads
    # so, move the downloaded data to persistent storage regularly, or configure the downloads/incomplete dirs to point to persisted storage (in nixpkgs slskd config)
    { user = "slskd"; group = "media"; path = "/var/lib/slskd"; method = "bind"; }
  ];
  sops.secrets."slskd_env" = {
    owner = config.users.users.slskd.name;
    mode = "0400";
  };

  users.users.slskd.extraGroups = [ "media" ];

  sane.ports.ports."50300" = {
    protocol = [ "tcp" ];
    # visibleTo.ovpns = true;  #< not needed: it runs in the ovpns namespace
    description = "colin-soulseek";
  };

  sane.dns.zones."uninsane.org".inet.CNAME."soulseek" = "native";

  services.nginx.virtualHosts."soulseek.uninsane.org" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${config.sane.netns.ovpns.veth.netns.ipv4}:5030";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  services.slskd.enable = true;
  services.slskd.domain = null;  # i'll manage nginx for it
  services.slskd.group = "media";
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
      # "[Audioooks]/var/media/Books/Audiobooks"
      # "[Books]/var/media/Books/Books"
      # "[Manga]/var/media/Books/Visual"
      # "[games]/var/media/games"
      "[Music]/var/media/Music"
      # "[Film]/var/media/Videos/Film"
      # "[Shows]/var/media/Videos/Shows"
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
    # run this behind the OVPN static VPN
    serviceConfig.NetworkNamespacePath = "/run/netns/ovpns";
    serviceConfig.ExecStartPre = [
      # abort if public IP is not as expected
      "${lib.getExe pkgs.sane-scripts.ip-check} --no-upnp --expect ${config.sane.netns.ovpns.wg.address.ipv4}"
    ];

    serviceConfig.Restart = lib.mkForce "always";  # exits "success" when it fails to connect to soulseek server
    serviceConfig.RestartSec = "60s";

    # hardening (systemd-analyze security slskd)
    # upstream nixpkgs specifies moderate defaults; these are supplementary
    serviceConfig.CapabilityBoundingSet = "";
    # serviceConfig.MemoryDenyWriteExecute = true;  #< XXX 2025-12-02: required
    serviceConfig.ProcSubset = "pid";
    serviceConfig.RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
    serviceConfig.SystemCallArchitectures = "native";
    serviceConfig.SystemCallFilter = [
      "@system-service"
      "~@privileged"
      # "~@resources"  #< XXX 2025-12-02: required
    ];
  };
}
