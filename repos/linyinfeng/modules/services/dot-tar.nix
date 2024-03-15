{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.services.dot-tar;

  cfgFile =
    if cfg.configFile != null then
      cfg.configFile
    else
      pkgs.runCommand "dot-tar.toml" { buildInputs = [ pkgs.remarshal ]; } ''
        remarshal -if json -of toml \
          < ${pkgs.writeText "dot-tar.json" (builtins.toJSON cfg.config)} \
          > $out
      '';
in
{
  options.services.dot-tar = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable dot-tar service.
      '';
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nur.repos.linyinfeng.dot-tar;
      defaultText = "pkgs.nur.repos.linyinfeng.dot-tar";
      description = ''
        dot-tar derivation to use.
      '';
    };
    configFile = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        Configuration file to use.
      '';
    };
    config = lib.mkOption {
      type = with lib.types; nullOr attrs;
      default = null;
      description = ''
        Configuration to use.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.configFile != null || cfg.config != null;
        message = "either config or configFile should be defined";
      }
      {
        assertion = !(cfg.configFile != null && cfg.config != null);
        message = "config conflicts with configFile";
      }
    ];

    systemd.services.dot-tar = {
      description = "Fetch file and tar it";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/dot-tar";
      };

      environment = {
        "ROCKET_CONFIG" = cfgFile;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
