{ config, lib, pkgs, ... }:

let
  # 2023/09/06: nixpkgs `transmission` defaults to old 3.00
  # 2024/02/15: some torrent trackers whitelist clients; everyone is still on 3.00 for some reason :|
  #             some do this via peer-id (e.g. baka); others via user-agent (e.g. MAM).
  #             peer-id format is essentially the same between 3.00 and 4.x (just swap the MAJOR/MINOR/PATCH numbers).
  #             user-agent format has changed. `Transmission/3.00` (old) v.s. `TRANSMISSION/MAJ.MIN.PATCH` (new).
  realTransmission = pkgs.transmission_4;
  realVersion = {
    major = lib.versions.major realTransmission.version;
    minor = lib.versions.minor realTransmission.version;
    patch = lib.versions.patch realTransmission.version;
  };
  package = realTransmission.overrideAttrs (upstream: {
    # `cmakeFlags = [ "-DTR_VERSION_MAJOR=3" ]`, etc, doesn't seem to take effect.
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace CMakeLists.txt \
        --replace-fail 'TR_VERSION_MAJOR "${realVersion.major}"' 'TR_VERSION_MAJOR "3"' \
        --replace-fail 'TR_VERSION_MINOR "${realVersion.minor}"' 'TR_VERSION_MINOR "0"' \
        --replace-fail 'TR_VERSION_PATCH "${realVersion.patch}"' 'TR_VERSION_PATCH "0"' \
        --replace-fail 'set(TR_USER_AGENT_PREFIX "''${TR_SEMVER}")' 'set(TR_USER_AGENT_PREFIX "3.00")'
    '';
  });
in
{
  sane.persist.sys.byStore.plaintext = [
    # TODO: mode? we need this specifically for the stats tracking in .config/
    { user = "transmission"; group = config.users.users.transmission.group; path = "/var/lib/transmission"; method = "bind"; }
  ];
  users.users.transmission.extraGroups = [ "media" ];

  services.transmission.enable = true;
  services.transmission.package = package;
  #v setting `group` this way doesn't tell transmission to `chown` the files it creates
  #  it's a nixpkgs setting which just runs the transmission daemon as this group
  services.transmission.group = "media";

  # transmission will by default not allow the world to read its files.
  services.transmission.downloadDirPermissions = "775";
  services.transmission.extraFlags = [
    # "--log-level=debug"
  ];

  services.transmission.settings = {
    # DOCUMENTATION/options list: <https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md#options>

    # message-level = 3;  #< enable for debug logging. 0-3, default is 2.
    # 0.0.0.0 => allow rpc from any host: we gate it via firewall and auth requirement
    rpc-bind-address = "0.0.0.0";
    #rpc-host-whitelist = "bt.uninsane.org";
    #rpc-whitelist = "*.*.*.*";
    rpc-authentication-required = true;
    rpc-username = "colin";
    # salted pw. to regenerate, set this plaintext, run nixos-rebuild, and then find the salted pw in:
    # /var/lib/transmission/.config/transmission-daemon/settings.json
    rpc-password = "{503fc8928344f495efb8e1f955111ca5c862ce0656SzQnQ5";
    rpc-whitelist-enabled = false;

    # hopefully, make the downloads world-readable
    # umask = 0;  #< default is 2: i.e. deny writes from world

    # force peer connections to be encrypted
    encryption = 2;

    # units in kBps
    speed-limit-down = 12000;
    speed-limit-down-enabled = true;
    speed-limit-up = 800;
    speed-limit-up-enabled = true;

    # see: https://git.zknt.org/mirror/transmission/commit/cfce6e2e3a9b9d31a9dafedd0bdc8bf2cdb6e876?lang=bg-BG
    anti-brute-force-enabled = false;

    download-dir = "/var/media";
    incomplete-dir = "/var/media/incomplete";
    # transmission regularly fails to move stuff from the incomplete dir to the main one, so disable:
    # TODO: uncomment this line!
    incomplete-dir-enabled = false;
  };

  systemd.services.transmission.after = [ "wireguard-wg-ovpns.service" ];
  systemd.services.transmission.partOf = [ "wireguard-wg-ovpns.service" ];
  systemd.services.transmission.serviceConfig = {
    # run this behind the OVPN static VPN
    NetworkNamespacePath = "/run/netns/ovpns";
    Restart = "on-failure";
    RestartSec = "30s";
  };

  # service to automatically backup torrents i add to transmission
  systemd.services.backup-torrents = {
    description = "archive torrents to storage not owned by transmission";
    script = ''
      ${pkgs.rsync}/bin/rsync -arv /var/lib/transmission/.config/transmission-daemon/torrents/ /var/backup/torrents/
    '';
  };
  systemd.timers.backup-torrents = {
    wantedBy = [ "multi-user.target" ];
    timerConfig = {
      OnStartupSec = "11min";
      OnUnitActiveSec = "240min";
    };
  };

  # transmission web client
  services.nginx.virtualHosts."bt.uninsane.org" = {
    # basicAuth is literally cleartext user/pw, so FORCE this to happen over SSL
    forceSSL = true;
    enableACME = true;
    # inherit kTLS;
    locations."/" = {
      # proxyPass = "http://ovpns.uninsane.org:9091";
      proxyPass = "http://10.0.1.6:9091";
    };
  };

  sane.dns.zones."uninsane.org".inet.CNAME."bt" = "native";
  sane.ports.ports."51413" = {
    protocol = [ "tcp" "udp" ];
    visibleTo.ovpn = true;
    description = "colin-bittorrent";
  };
}

