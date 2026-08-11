{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.anemoi;
in
{
  options.services.anemoi = {
    enable = lib.mkEnableOption "anemoi";
    package = lib.mkPackageOption pkgs "anemoi";
    configFile = lib.mkOption {
      type = lib.types.path;
    };
    verbose = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.anemoi = {
      description = "Anemoi DDNS";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        DynamicUser = true;
        WorkingDirectory = "\${STATE_DIRECTORY}";
        StateDirectory = "anemoi";
        ExecStart = "${lib.getExe cfg.package}${lib.optionalString cfg.verbose " -v"} --config ${cfg.configFile}";
        Restart = "always";
      };
    };
  };
}
