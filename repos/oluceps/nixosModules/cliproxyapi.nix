{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    mkOption
    types
    mkPackageOption
    mkEnableOption
    mkIf
    ;

  cfg = config.services.cliproxyapi;
in
{
  options.services.cliproxyapi = {
    enable = mkEnableOption "CLIProxyAPI service";

    package = mkPackageOption pkgs "cliproxyapi" { };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Configuration for CLIProxyAPI, will be written to `.cli-proxy-api/config.yaml`
        in the state directory.
      '';
    };

    environmentFile = mkOption {
      type = types.nullOr (types.either types.str types.path);
      default = null;
      description = ''
        File containing environment variables to be passed to the CLIProxyAPI service.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.cliproxyapi = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "CLIProxyAPI Daemon";

      preStart = mkIf (cfg.settings != { }) ''
        mkdir -p /var/lib/cliproxyapi/.cli-proxy-api
        cat ${
          pkgs.formats.yaml { }.generate "config.yaml" cfg.settings
        } > /var/lib/cliproxyapi/.cli-proxy-api/config.yaml
      '';

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "cliproxyapi";
        # HOME is automatically set to /var/lib/cliproxyapi due to StateDirectory with DynamicUser
        ExecStart = "${lib.getExe cfg.package}";
        EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
        Restart = "on-failure";
      };
    };
  };
}
