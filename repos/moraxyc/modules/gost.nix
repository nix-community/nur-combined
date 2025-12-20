{
  lib,
  pkgs,
  config,
  utils,
  ...
}:

let
  cfg = config.services.gost';
  settingsFormat = pkgs.formats.json { };
  gen-config = pkgs.writeShellApplication {
    name = "gen-config";
    runtimeInputs = with pkgs; [ jq ];
    text = utils.genJqSecretsReplacementSnippet cfg.settings "/run/gost/config.json" + ''
      chown --reference=/run/gost /run/gost/config.json
    '';
  };
in
{
  options = {
    services.gost' = {
      enable = lib.mkEnableOption "";

      package = lib.mkPackageOption pkgs "gost" { };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = settingsFormat.type;
        };
        default = { };
        description = ''
          The gost configuration, see https://gost.run/ for documentation.

          Options containing secret data should be set to an attribute set
          containing the attribute `_secret` - a string pointing to a file
          containing the value the option should be set to.
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.gost = {
      enableStrictShellChecks = true;
      serviceConfig = {
        RuntimeDirectory = "gost";
        ExecStart = "${lib.getExe cfg.package} -C /run/gost/config.json";
        ExecStartPre = "+${lib.getExe gen-config}";

        # Harden
        ReadWritePaths = [ "/run/gost" ];
        NoNewPrivileges = true;
        DynamicUser = true;
        RemoveIPC = true;
        PrivateMounts = true;
        RestrictSUIDSGID = true;
        ProtectHostname = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
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
        ProtectSystem = "strict";
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
  };
}
