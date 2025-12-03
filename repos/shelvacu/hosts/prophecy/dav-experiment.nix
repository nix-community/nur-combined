{
  lib,
  pkgs,
  config,
  vaculib,
  ...
}:
let
  path = "/dav-experiment";
  dufsConfig = {
    bind = "/var/lib/dav-experiment/socket";
    allow-all = true;
    enable-cors = false;
    render-try-index = true;
    render-spa = true;
    serve-path = path;

    auth = [
      "s:$6$WNI1472ebgQg9zjk$4qeOLarhHJNxNHaAkzztJMN8fzOb6iQm7KTp0SuvYWSvfFORjcNSXNBsKTLRSox2LOSYYwWSyYv/u6lQ9VstF1@/:rw"
    ];
  };
  dufsConfigFile = pkgs.writeText "dufs-config.yaml" (builtins.toJSON dufsConfig);
in
{
  users.users.dav-experiment = {
    isSystemUser = true;
    group = "dav-experiment";
    home = "/var/lib/dav-experiment";
  };
  users.groups.dav-experiment = { };

  environment.persistence."/persistent".directories = [
    {
      directory = path;
      user = "dav-experiment";
      group = "dav-experiment";
      mode = vaculib.accessModeStr { user = "all"; };
    }
  ];

  systemd.tmpfiles.settings."10-whatever"."/var/lib/dav-experiment".d = {
    user = "dav-experiment";
    group = "dav-experiment";
    mode = vaculib.accessModeStr {
      user = "all";
      group.execute = true;
    };
  };

  services.caddy.virtualHosts."dav-experiment.shelvacu.com" = {
    vacu.hsts = "preload";
    extraConfig = ''
      reverse_proxy unix/${dufsConfig.bind}
    '';
  };

  users.users.${config.services.caddy.user}.extraGroups = [ "dav-experiment" ];

  systemd.services.dav-experiment = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    description = "dufs server";
    serviceConfig = {
      Type = "exec";
      ExecStart = "${lib.getExe pkgs.dufs-vacu} --config ${dufsConfigFile}";
      KillMode = "mixed";
      TimeoutStopSec = "10s";
      User = "dav-experiment";
      Group = "dav-experiment";
      UMask = vaculib.maskStr {
        user = "allow";
        group = {
          read = "allow";
          write = "allow";
          execute = "forbid";
        };
      };

      SocketBindDeny = "any";
      RestrictNetworkInterfaces = "";
      ProtectProc = "invisible";
      ProcSubset = "pid";
      DeviceAllow = "";
      DevicePolicy = "closed";

      BindPaths = [
        path
        "/var/lib/dav-experiment"
      ];
      BindReadOnlyPaths = [ "/nix/store" ];

      CapabilityBoundingSet = "";
      AmbientCapabilities = [ ];
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;

      # InaccessiblePaths = [ "/" ];
      # ReadOnlyPaths = [ "/nix/store" ];
      # ReadWritePaths = [ path "/var/lib/dav-experiment" ];
      PrivateTmp = true;
      PrivateDevices = true;
      PrivateNetwork = true;
      PrivateIPC = true;
      PrivatePIDs = true;
      PrivateUsers = true;
      ProtectHostname = true;
      ProtectClock = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = "strict";

      RestrictAddressFamilies = [
        "AF_UNIX"
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
        "~@resources"
      ];
      SystemCallArchitectures = "native";
    };
  };
}
