{ config, lib, pkgs, ... }:

let
  # 2023/09/06: nixpkgs `transmission` defaults to old 3.00
  # 2024/02/15: some torrent trackers whitelist clients; everyone is still on 3.00 for some reason :|
  #             some do this via peer-id (e.g. baka); others via user-agent (e.g. MAM).
  #             peer-id format is essentially the same between 3.00 and 4.x (just swap the MAJOR/MINOR/PATCH numbers).
  #             user-agent format has changed. `Transmission/3.00` (old) v.s. `TRANSMISSION/MAJ.MIN.PATCH` (new).
  # package = pkgs.transmission_3;
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
  download-dir = "/var/media/torrents";  #< keep in sync with consts embedded in `torrent-done`
  torrent-done = pkgs.static-nix-shell.mkBash {
    pname = "torrent-done";
    srcRoot = ./.;
    pkgs = {
      inherit (pkgs)
        acl
        coreutils
        findutils
        rsync
      ;
    };
    merge = "prepend";
  };
in
{
  sane.persist.sys.byStore.private = [
    # TODO: mode? we need this specifically for the stats tracking in .config/
    { user = "transmission"; group = config.users.users.transmission.group; path = "/var/lib/transmission"; method = "bind"; }
    { user = "transmission"; group = config.users.users.transmission.group; path = "/var/backup/torrents"; method = "bind"; }
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
    # ovpns.veth.netns.ipv4 => allow rpc only from the root servo ns. it'll tunnel things to the net, if need be.
    rpc-bind-address = config.sane.netns.ovpns.veth.netns.ipv4;
    #rpc-host-whitelist = "bt.uninsane.org";
    #rpc-whitelist = "*.*.*.*";
    rpc-authentication-required = true;
    rpc-username = "colin";
    # salted pw. to regenerate, set this plaintext, run nixos-rebuild, and then find the salted pw in:
    # /var/lib/transmission/.config/transmission-daemon/settings.json
    rpc-password = "{503fc8928344f495efb8e1f955111ca5c862ce0656SzQnQ5";
    rpc-whitelist-enabled = false;

    # force behind ovpns in case the NetworkNamespace fails somehow
    bind-address-ipv4 = config.sane.netns.ovpns.wg.address.ipv4;
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
    script-torrent-done-filename = lib.getExe torrent-done;
  };

  # run this behind the OVPN static VPN
  sane.netns.ovpns.services = [ "transmission" ];
  systemd.services.transmission = {
    environment.TR_DEBUG = "1";
    serviceConfig.ExecStartPre = [
      # abort if public IP is not as expected
      "${lib.getExe pkgs.sane-scripts.ip-check} --no-upnp --expect ${config.sane.netns.ovpns.wg.address.ipv4}"
    ];

    serviceConfig.Restart = "on-failure";
    serviceConfig.RestartSec = "30s";
    serviceConfig.BindPaths = [ "/var/media" ];  #< so it can move completed torrents into the media library
    unitConfig.RequiresMountsFor = [ "/var/media" ];  # ensure the media is available *before* binding /var/media into the mount ns else the actual media will never appear in the daemon's namespace.
    serviceConfig.SystemCallFilter = lib.mkForce [
      # the torrent-done script does stuff which fails the nixos default syscall filter.
      # allow a bunch of stuff, speculatively, to hopefully fix that:
      "@aio"
      "@basic-io"
      "@chown"
      "@file-system"
      "@io-event"
      "@process"
      "@sandbox"
      "@sync"
      "@system-service"
      "quotactl"
    ];
  };

  # service to automatically backup torrents i add to transmission
  systemd.services.backup-torrents = {
    description = "archive torrents to storage not owned by transmission";
    script = ''
      ${lib.getExe pkgs.rsync} -arv /var/lib/transmission/.config/transmission-daemon/torrents/ /var/backup/torrents/
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
      proxyPass = "http://${config.sane.netns.ovpns.veth.netns.ipv4}:9091";
      recommendedProxySettings = true;
    };
  };

  sane.dns.zones."uninsane.org".inet.CNAME."bt" = "native";
  sane.ports.ports."51413" = {
    protocol = [ "tcp" "udp" ];
    # visibleTo.ovpns = true;  #< not needed: it runs in the ovpns namespace
    description = "colin-bittorrent";
  };

  # see <repo:nixos/nixpkgs:nixos/modules/services/torrent/transmission.nix>;
  # transmission itself has an apparmor profile,
  # and is knowledgeable enough to also inherit the profile of the torrent-done script...
  # but unless i define such a profile, then apparmor will complain:
  # > Feb 08 02:01:24 servo kernel: audit: type=1400 audit(...): apparmor="DENIED" operation="exec" class="file" info="profile transition not found" error=-13 profile="/nix/store/05pbi2xpappimpzl43mbcan7csl3ngni-transmission-4.0.6/bin/transmission-daemon" name="/nix/store/mgf31pv0ar816nw15rizq734vhz2ggk3-torrent-done-0.1.0/bin/torrent-done" pid=... comm="transmission-da" requested_mask="x" denied_mask="x" fsuid=70 ouid=0 target="&@{dirs}"
  # N.B.: `$path/bin/** pixr` means: the referenced path can be read or executed; when executed we attempt an apparmor profile transition but fallback to inheriting the current profile if no explicit profile is defined.
  # - TODO: what i actually want is "stacked" profiles; i.e. intersect the profiles. <https://gitlab.com/apparmor/apparmor/-/wikis/AppArmorStacking>
  # N.B.: `abstractions/consoles` is included for when you run this interactively.
  security.apparmor.policies."bin.torrent-done".profile = ''
    abi <abi/4.0>,
    include <tunables/global>
    profile ${lib.getExe torrent-done} {
      include <abstractions/base>
      include <abstractions/consoles>
      include "${
        pkgs.apparmorRulesFromClosure
          { name = "torrent-done"; additionalRules = [ "$path/bin/** pixr" ]; }
          [ torrent-done ]
      }"
      mr ${lib.getExe torrent-done},
      /var/media/** rw,
      include if exists <local/bin.torrent-done>
    }
  '';
}

