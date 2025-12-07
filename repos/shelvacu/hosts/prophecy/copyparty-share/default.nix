{
  pkgs,
  config,
  vaculib,
  lib,
  ...
}:
let
  mainDir = "/propdata/copyparty-share";
  ftpPort = 21;
  ftpsPort = 990;
  singleTCPPorts = [
    ftpPort
    ftpsPort
  ];
  singleUDPPorts = [
    1900 # ssdp
    5353 # mDNS
  ];
  ftpPortRange = {
    from = 12000;
    to = 12999;
  };
  socketDir = "/var/lib/copyparty-share-socket";
  socketPath = "${socketDir}/socket.unix";
  package = pkgs.copyparty.override {
    withHashedPasswords = true;
    withCertgen = true;
    withThumbnails = true;
    withFastThumbnails = true;
    withMediaProcessing = true;
    withZeroMQ = false;
    withFTP = true;
    withFTPS = true;
    withTFTP = false;
    withSMB = false;
    withMagic = true;
  };
  rootPkg = pkgs.callPackage ./root-derivation.nix { };
  configFile = pkgs.writeText "copyparty-share.conf" ''
    [global]
      j: 2
      hist:/var/lib/copyparty-share
      usernames
      e2dsa
      e2ts
      daw
      shr: /s
      shr-adm: shelvacu
      allow-flac
      allow-wav
      z
      name: 2e14
      ftp: ${toString ftpPort}
      ftps: ${toString ftpsPort}
      ftp-pr: ${toString ftpPortRange.from}-${toString ftpPortRange.to}
      no-clone
      xdev
      ipu: 10.78.76.0/22=lan
      no-robots
      i: 10.78.79.22,unix:770:${toString config.users.groups.copyparty-share-socket.gid}:${socketPath}
      ah-alg: argon2
      u2sort: n
      df: 1T
      chmod-f: 660
      chmod-d: 770
      plain-ip
      rproxy: -1
      http-no-tcp
      zm-http: 80
      zm-https: 443
      idp-h-usr: X-Auth-Request-Preferred-Username
      idp-h-grp: X-Auth-Request-Group
      auth-ord: idp,pw,ipu
      idp-adm: shelvacu
      idp-login: https://2e14.sv.mt/oauth2/start?rd={dst}
      idp-login-t: Login with id.shelvacu
      idp-logout: https://2e14.sv.mt/oauth2/sign_out
      idp-store: 3
      log-conn
      no-ansi

    [accounts]
      # shelvacu: +7GvyoieOAbzXd3guJru24uAxHzZ4tHYL
      shelvacu-fw-obsidian: +AC4eJ9Ztd3Tb2sO6zi9KvfhUeE-UhrWf
      shelvacu-pixel9pro-obsidian: +_68si1x8KkbAumjZMekTg6G7mDkvnCZX
      # lan is added to the list as a workaround until https://github.com/9001/copyparty/issues/959 is fixed
      lan: +aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

    [groups]
      shelvacu-obsidian: shelvacu-fw-obsidian, shelvacu-pixel9pro-obsidian
      not-people: lan, shelvacu-fw-obsidian, shelvacu-pixel9pro-obsidian
      general_access:

    [/]
      ${rootPkg}
      accs:
        r: @acct

    [/archive]
      /propdata/archive
      accs:
        r: shelvacu

    [/chaosbox]
      ${mainDir}/chaosbox
      accs:
        rwm: @general_access,lan
        A: shelvacu
      flags:
        dots

    [/media]
      /propdata/media
      accs:
        r: @general_access,lan
      flags:
        -xdev
        xvol

    [/ppl]
      ${vaculib.path ./ppl-folder}
      accs:
        r: @acct

    [/ppl/''${u%-not-people}]
      ${mainDir}/ppl/''${u}
      accs:
        rwmd.: ''${u}

    [/ppl/shelvacu/obsidian]
      ${mainDir}/ppl/shelvacu/obsidian
      accs:
        rwmd.: @shelvacu-obsidian
        A: shelvacu

    [/general_access]
      ${pkgs.emptyDirectory}
      accs:
        r: @general_access
  '';
in
{
  networking.firewall.allowedTCPPorts = singleTCPPorts;
  networking.firewall.allowedUDPPorts = singleUDPPorts;
  networking.firewall.allowedTCPPortRanges = [ ftpPortRange ];
  users.users.copyparty-share = {
    isSystemUser = true;
    home = "/var/lib/copyparty-share";
    group = "copyparty-share";
  };
  users.groups.copyparty-share = { };
  users.groups.copyparty-share-socket = {
    gid = 981;
    members = [
      "copyparty-share"
      "caddy"
    ];
  };
  users.groups.media.members = [ "copyparty-share" ];

  systemd.tmpfiles.settings."10-whatever" =
    let
      userOnly = vaculib.accessModeStr { user = "all"; };
    in
    {
      ${socketDir}.d = {
        user = "copyparty-share";
        group = "copyparty-share-socket";
        mode = vaculib.accessModeStr {
          user = "all";
          group = "all";
        };
      };
      "/var/lib/copyparty-share".d = {
        user = "copyparty-share";
        group = "copyparty-share";
        mode = userOnly;
      };
      "${mainDir}/root".d = {
        user = "copyparty-share";
        group = "copyparty-share";
        mode = userOnly;
      };
      "${mainDir}/chaosbox".d = {
        user = "copyparty-share";
        group = "copyparty-share";
        mode = userOnly;
      };

      "/propdata/media/readme.md"."L".argument = vaculib.path ./media-readme.md;
    };

  systemd.services.copyparty-share = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "exec";
      ExecStart = "${package}/bin/copyparty -c ${configFile}";
      User = "copyparty-share";
      Group = "copyparty-share";
      StateDirectory = "copyparty-share";
      StateDirectoryMode = vaculib.accessModeStr { user = "all"; };

      BindPaths = [
        mainDir
        socketDir
      ];
      BindReadOnlyPaths = [
        configFile
        "/propdata/media:/propdata/media:rbind"
        "/propdata/archive"
      ];

      UMask = vaculib.maskStr { user = "allow"; };
      # RestrictNetworkInterfaces = "";
      ProtectProc = "invisible";
      ProcSubset = "pid";
      DeviceAllow = "";
      DevicePolicy = "closed";
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      NoNewPrivileges = false;
      ProtectSystem = "strict";
      ProtectHome = true;

      PrivateTmp = true;
      PrivateDevices = true;
      PrivateIPC = true;
      PrivatePIDs = true;
      PrivateUsers = false;
      ProtectHostname = true;
      ProtectClock = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = "strict";

      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];

      RestrictNamespaces = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RemoveIPC = true;
      PrivateMounts = true;
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
        "@chown"
      ];
      SystemCallArchitectures = "native";

      SocketBindAllow = [
        "tcp:${toString ftpPortRange.from}-${toString ftpPortRange.to}"
      ]
      ++ (map (p: "tcp:${toString p}") singleTCPPorts)
      ++ (map (p: "udp:${toString p}") singleUDPPorts);
      SocketBindDeny = "any";
    };
  };

  services.caddy.virtualHosts."2e14.t2d.lan" = {
    vacu.hsts = false;
    extraConfig = ''
      tls /var/lib/caddy/2e14.t2d.lan.crt /var/lib/caddy/2e14.t2d.lan.key
      reverse_proxy unix/${socketPath} {
        header_up -X-Client-Auth-Fingerprint
        header_up -X-Forwarded-User
        header_up -X-Forwarded-Groups
        header_up -X-Forwarded-Email
        header_up -X-Forwarded-Preferred-Username
        header_up -X-Auth-*
      }
    '';
  };

  vacu.oauthProxy.instances."two_e14" = {
    appDomain = "2e14.sv.mt";
    caddyConfig = ''
      reverse_proxy unix/${socketPath}
    '';
    requireOauth = false;
    displayName = "2e14 (copyparty)";
    kanidmMembers = [ "general_access" ];
  };
  services.kanidm.provision.systems.oauth2.two_e14 = {
    imageFile = "${pkgs.srcOnly package}/docs/logo.svg";
    supplementaryScopeMaps.general_access = [ "general_access" ];
  };
  services.caddy.virtualHosts."2e14.sv.mt".vacu.hsts = "preload";
  services.caddy.virtualHosts."copyparty.sv.mt" = {
    vacu.hsts = "preload";
    serverAliases = [
      "copy.sv.mt"
      "copyparty.sv.mt"
      "files.sv.mt"
      "f.sv.mt"
      "copy.shelvacu.com"
      "copyparty.shelvacu.com"
      "files.shelvacu.com"
    ];
    extraConfig = ''redir * https://2e14.sv.mt{uri}'';
  };

  vacu.packages = lib.singleton (
    pkgs.writers.writeBashBin "copyparty-new-account-hash" ''
      source ${pkgs.shellvaculib.file}
      svl_exact_args $# 1
      declare new_username="$1"
      declare new_password
      new_password="$(head -c 24 < /dev/urandom | base64)"
      declare fake_home
      fake_home="$(mktemp -d)"
      trap 'rm -rf -- "$fake_home"' EXIT
      cd -- "$fake_home"
      install --mode=u=rwx,go= -d .config/copyparty
      sudo install --mode=u=rw,go= --owner="$USER" {/var/lib/copyparty-share/,}.config/copyparty/ah-salt.txt
      printf "%s:%s\n" "$new_username" "$new_password" | HOME="$PWD" ${package}/bin/copyparty --ah-alg argon2 --ah-gen -
      echo "user: $new_username"
      echo "pass: $new_password"
    ''
  );
}
