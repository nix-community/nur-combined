{
  pkgs,
  pkgsUnstable,
  lib,
  vaculib,
  ...
}:
let
  socketDir = "/var/run/radicale-socket";
  socketPath = "${socketDir}/socket.unix";
  thePy = pkgsUnstable.python3.withPackages (pyPkgs: [
    pyPkgs.granian
    (pyPkgs.toPythonModule pkgsUnstable.radicale)
  ]);
  granianArgsList = [
    "--interface"
    "wsgi"
    "--uds"
    socketPath
    # uncomment when granian 2.5.6 or later is available
    # "--uds-permissions" (vaculib.accessModeStr { all = "all"; })
    "radicale:application"
  ];
  # make new entries with
  # uuid | tee /dev/fd/2 | nix shell nixpkgs#apacheHttpd --command htpasswd -nBi newusername
  hashes = [
    # in bitwarden
    "$2y$05$t1yu.c7zJq4pPnC2cuAdpOLx0xCoY8vbcqe8qlnLGJpLrhNn/bc2G"
    # pixel9pro davx5
    "$2y$05$VigQfxQoLDPzKhxC.ti0NeFnAJTNeP7mbKc1VU0Ysqg/G0sDYbeSO"
    # thunderbird @ fw
    "$2y$05$xAndl8cHx8azp8/gNnpKO.RyxC5WPva8/QEv1CxbzL/hhYwYM2nP6"
  ];
  htpasswd = pkgs.writeText "radicale-users.htpasswd" (
    lib.concatMapStringsSep "\n" (hash: "shelvacu:${hash}") hashes
  );
  radicale = rec {
    settings = {
      storage.filesystem_cache_folder = "/var/cache/radicale";
      auth = {
        type = "htpasswd";
        htpasswd_filename = htpasswd;
        lc_username = true;
      };
    };
    formatter = pkgs.formats.ini {
      listToValue = lib.concatMapStringsSep ", " (lib.generators.mkValueStringDefault { });
    };
    configFile = formatter.generate "radicale.conf" settings;
  };
in
{
  imports = [ { options.vacu.debug.radicale = vaculib.mkOutOption thePy; } ];
  users.users.radicale = {
    isSystemUser = true;
    group = "radicale";
  };
  users.groups.radicale = { };
  users.groups.radicale-socket.members = [
    "caddy"
    "radicale"
  ];
  systemd.tmpfiles.settings.whatever.${socketDir}.d = {
    mode = vaculib.accessModeStr {
      user = "all";
      group = "all";
    };
    user = "radicale";
    group = "radicale-socket";
  };
  systemd.services.radicale = {
    confinement = {
      enable = true;
      packages = [
        htpasswd
        radicale.configFile
        pkgs.coreutils
      ];
    };
    environment.RADICALE_CONFIG = radicale.configFile;
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      rm -- ${socketPath} || true
    '';
    serviceConfig = {
      ExecStart = "${thePy}/bin/granian ${lib.escapeShellArgs granianArgsList}";
      Type = "simple";
      User = "radicale";
      Group = "radicale";
      StateDirectory = "radicale";
      StateDirectoryMode = vaculib.accessModeStr { user = "all"; };
      CacheDirectory = "radicale";
      CacheDirectoryMode = vaculib.accessModeStr { user = "all"; };
      BindPaths = [ socketDir ];

      CapabilityBoundingSet = "";
      DeviceAllow = [
        "/dev/urandom:r"
        "/dev/stdin"
      ];
      DevicePolicy = "strict";
      IPAddressDeny = "any";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProcSubset = "pid";
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RemoveIPC = true;
      RestrictAddressFamilies = [ "AF_UNIX" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
        "~@resources"
      ];
      UMask = "0000";
      WorkingDirectory = "/var/lib/radicale";
    };
  };

  services.caddy.virtualHosts."radicale.shelvacu.com" = {
    vacu.hsts = "preload";
    extraConfig = ''
      reverse_proxy unix/${socketPath}
    '';
  };
}
