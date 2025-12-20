{
  lib,
  pkgs,
  config,
  utils,
  ...
}:

let
  cfg = config.services.mcsmanager;
in
{
  options = {
    services.mcsmanager = {
      enable = lib.mkEnableOption "MSCManager";
      package = lib.mkPackageOption pkgs "mcsmanager" { };

      daemon = {
        enable = lib.mkEnableOption "MSCManager Daemon, note default port 24444";
        dockerSupport = lib.mkEnableOption "";
      };

      web = {
        enable = lib.mkEnableOption "MSCManager Web, note default port 23333";
      };
    };
  };
  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.daemon.enable || cfg.web.enable;
        message = "Must enable at least one of Daemon or Web.";
      }
    ];

    systemd.services = {
      mcsm-web = lib.mkIf cfg.web.enable {
        enableStrictShellChecks = true;
        serviceConfig = {
          StateDirectory = "mcsm-web";
          StateDirectoryMode = "0750";
          WorkingDirectory = "/var/lib/mcsm-web";
          ExecStart = lib.getExe' cfg.package "mcsm-web";

          # Harden
          ReadWritePaths = [ "/var/lib/mcsm-web" ];
          NoNewPrivileges = true;
          DynamicUser = true;
          RemoveIPC = false;
          PrivateMounts = true;
          RestrictSUIDSGID = true;
          ProtectHostname = true;
          LockPersonality = true;
          MemoryDenyWriteExecute = false; # required by V8 JIT
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "full";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          CapabilityBoundingSet = "";
          UMask = "0177";
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];
        };
        wantedBy = [ "multi-user.target" ];
      };
      mcsm-daemon = lib.mkIf cfg.daemon.enable {
        enableStrictShellChecks = true;
        serviceConfig = {
          StateDirectory = "mcsm-daemon";
          StateDirectoryMode = "0750";
          WorkingDirectory = "/var/lib/mcsm-daemon";
          ExecStart = lib.getExe' cfg.package "mcsm-daemon";

          # Harden
          ReadWritePaths = [ "/var/lib/mcsm-daemon" ];
          NoNewPrivileges = true;
          DynamicUser = true;
          RemoveIPC = false;
          PrivateMounts = true;
          RestrictSUIDSGID = true;
          ProtectHostname = true;
          LockPersonality = true;
          MemoryDenyWriteExecute = false; # required by V8 JIT
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "full";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          CapabilityBoundingSet = "";
          UMask = "0177";
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ]
          ++ lib.optional cfg.daemon.dockerSupport "AF_UNIX";
          SupplementaryGroups = lib.optional cfg.daemon.dockerSupport "docker";
          BindPaths = lib.optional cfg.daemon.dockerSupport "/run/docker.sock";
        };
        wantedBy = [ "multi-user.target" ];
      };
    };
  };
}
