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
  download-dir = "/var/media/torrents";
  torrent-done = pkgs.writeShellApplication {
    name = "torrent-done";
    runtimeInputs = with pkgs; [
      acl
      coreutils
      findutils
      rsync
      util-linux
    ];
    text = ''
      destructive() {
        if [ -n "''${TR_DRY_RUN-}" ]; then
          echo "$*"
        else
          "$@"
        fi
      }
      if [[ "$TR_TORRENT_DIR" =~ ^.*freeleech.*$ ]]; then
        # freeleech torrents have no place in my permanent library
        echo "freeleech: nothing to do"
        exit 0
      fi
      if ! [[ "$TR_TORRENT_DIR" =~ ^${download-dir}/.*$ ]]; then
        echo "unexpected torrent dir, aborting: $TR_TORRENT_DIR"
        exit 0
      fi

      REL_DIR="''${TR_TORRENT_DIR#${download-dir}/}"
      MEDIA_DIR="/var/media/$REL_DIR"

      destructive mkdir -p "$(dirname "$MEDIA_DIR")"
      destructive rsync -arv "$TR_TORRENT_DIR/" "$MEDIA_DIR/"
      # make the media rwx by anyone in the group
      destructive find "$MEDIA_DIR" -type d -exec setfacl --recursive --modify d:g::rwx,o::rx {} \;
      destructive find "$MEDIA_DIR" -type d -exec chmod g+rw,a+rx {} \;

      # if there's a single directory inside the media dir, then inline that
      subdirs=("$MEDIA_DIR"/*)
      if [ ''${#subdirs} -eq 1 ]; then
        dirname="''${subdirs[0]}"
        if [ -d "$dirname" ]; then
          mv "$dirname"/* "$MEDIA_DIR/" && rmdir "$dirname"
        fi
      fi

      # remove noisy files:
      find "$MEDIA_DIR/" -type f \(\
           -iname 'www.YTS.*.jpg' \
        -o -iname 'WWW.YIFY*.COM.jpg' \
        -o -iname 'YIFY*.com.txt' \
        -o -iname 'YTS*.com.txt' \
        \) -exec rm {} \;

      # dedupe the whole media library.
      # yeah, a bit excessive: move this to a cron job if that's problematic.
      destructive hardlink /var/media --reflink=always --ignore-time --verbose
    '';
  };
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
    # 10.0.1.6 => allow rpc only from the root servo ns. it'll tunnel things to the net, if need be.
    rpc-bind-address = "10.0.1.6";
    #rpc-host-whitelist = "bt.uninsane.org";
    #rpc-whitelist = "*.*.*.*";
    rpc-authentication-required = true;
    rpc-username = "colin";
    # salted pw. to regenerate, set this plaintext, run nixos-rebuild, and then find the salted pw in:
    # /var/lib/transmission/.config/transmission-daemon/settings.json
    rpc-password = "{503fc8928344f495efb8e1f955111ca5c862ce0656SzQnQ5";
    rpc-whitelist-enabled = false;

    # force behind ovpns in case the NetworkNamespace fails somehow
    bind-address-ipv4 = "185.157.162.178";
    port-forwarding-enabled = false;

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

    inherit download-dir;
    incomplete-dir = "${download-dir}/incomplete";
    # transmission regularly fails to move stuff from the incomplete dir to the main one, so disable:
    incomplete-dir-enabled = false;

    # env vars available in script:
    # - TR_APP_VERSION - Transmission's short version string, e.g. `4.0.0`
    # - TR_TIME_LOCALTIME
    # - TR_TORRENT_BYTES_DOWNLOADED - Number of bytes that were downloaded for this torrent
    # - TR_TORRENT_DIR - Location of the downloaded data
    # - TR_TORRENT_HASH - The torrent's info hash
    # - TR_TORRENT_ID
    # - TR_TORRENT_LABELS - A comma-delimited list of the torrent's labels
    # - TR_TORRENT_NAME - Name of torrent (not filename)
    # - TR_TORRENT_TRACKERS - A comma-delimited list of the torrent's trackers' announce URLs
    script-torrent-done-enabled = true;
    script-torrent-done-filename = "${torrent-done}/bin/torrent-done";
  };

  systemd.services.transmission.after = [ "wireguard-wg-ovpns.service" ];
  systemd.services.transmission.partOf = [ "wireguard-wg-ovpns.service" ];
  systemd.services.transmission.serviceConfig = {
    # run this behind the OVPN static VPN
    NetworkNamespacePath = "/run/netns/ovpns";
    Restart = "on-failure";
    RestartSec = "30s";
    BindPaths = [ "/var/media" ];  #< so it can move completed torrents into the media library
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

