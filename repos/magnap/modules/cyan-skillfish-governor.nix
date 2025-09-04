{
  options,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hardware.cyan-skillfish-governor;
  settingsFormat = pkgs.formats.toml { };
in
{
  _class = "nixos";

  options.services.hardware.cyan-skillfish-governor = {
    enable = lib.mkEnableOption "Cyan Skillfish GPU governor";
    package = lib.mkPackageOption pkgs "cyan-skillfish-governor" { };
    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
      };
      default = { };
      description = ''
        Governor configuration,
        see <link xlink:href="https://github.com/Magnap/cyan-skillfish-governor/README.md"/>
        for supported values.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.cyan-skillfish-governor = {
      description = "Cyan Skillfish GPU Governor";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = lib.escapeShellArgs [
          (lib.getExe cfg.package)
          (settingsFormat.generate "governor-config.toml" cfg.settings)
        ];
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
