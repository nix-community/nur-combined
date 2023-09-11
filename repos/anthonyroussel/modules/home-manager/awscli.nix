{ config, lib, pkgs, ... }:

let
  cfg = config.programs.awscli;
  iniFormat = pkgs.formats.ini { };

in {
  meta.maintainers = [ lib.maintainers.anthonyroussel ];

  options.programs.awscli = {
    enable = lib.mkEnableOption "AWS CLI tool";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.awscli2;
      defaultText = lib.literalExpression "pkgs.awscli2";
      description = "Package providing {command}`aws`.";
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = iniFormat.type;
      };
      default = { };
      description = "Configuration written to {file}`$HOME/.aws/config`.";
      example = lib.literalExpression ''
        {
          default = {
            region = "eu-west-3";
            output = "json";
          };
        };
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file."${config.home.homeDirectory}/.aws/config".source =
      iniFormat.generate "config-${config.home.username}" cfg.settings;
  };
}
