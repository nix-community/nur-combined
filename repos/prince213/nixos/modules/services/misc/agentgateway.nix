{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.agentgateway;
  format = pkgs.formats.yaml_1_2 { };
  configFile = format.generate "config.yaml" cfg.settings;
in
{
  options.services.agentgateway = {
    enable = lib.mkEnableOption "Agentgateway";
    package = lib.mkPackageOption pkgs "agentgateway" { };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = format.type;
        options = {
        };
      };
      default = { };
      description = ''
        Configuration, see <https://agentgateway.dev/docs/standalone/latest/documentation/configuration/overview/> for documentation.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.agentgateway = {
      description = "Agentgateway";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "agentgateway";
        Group = "agentgateway";
        DynamicUser = true;

        ExecStart = "${lib.getExe cfg.package} -f ${configFile}";
      };
    };
  };
}
