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

    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable AWS CLI's Bash integration.";
    };

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable AWS CLI's Zsh integration.";
    };

    settings = lib.mkOption {
      type = lib.types.submodule { freeformType = iniFormat.type; };
      default = { };
      description = "Configuration written to {file}`$HOME/.aws/config`.";
      example = lib.literalExpression ''
        {
          "default" = {
            region = "eu-west-3";
            output = "json";
          };
        };
      '';
    };

    credentials = lib.mkOption {
      type = lib.types.submodule { freeformType = iniFormat.type; };
      default = { };
      description = ''
        A credentials to define in the aws credentials file.
        See https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html
      '';
      example = lib.literalExpression ''
        {
          "default" = {
            "credential_process" = "${pkgs.gopass}/bin/gopass show -u -n aws";
          };
        };
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file."${config.home.homeDirectory}/.aws/config".source =
      iniFormat.generate "aws-config-${config.home.username}" cfg.settings;

    home.file."${config.home.homeDirectory}/.aws/credentials".source =
      iniFormat.generate "aws-credentials-${config.home.username}"
      cfg.credentials;

    programs.bash.initExtra = lib.mkIf cfg.enableBashIntegration ''
      source ${cfg.package}/share/bash-completion/completions/aws
    '';

    programs.zsh.initExtra = lib.mkIf cfg.enableZshIntegration ''
      source ${cfg.package}/share/zsh/site-functions/aws_zsh_completer.sh
    '';
  };
}
