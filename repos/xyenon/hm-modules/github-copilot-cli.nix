{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.github-copilot-cli;

  shellIntegration = ''
    eval "$(github-copilot-cli alias -- "$0")"
  '';
in {
  meta.maintainers = [ maintainers.xyenon ];

  options.programs.github-copilot-cli = {
    enable = mkEnableOption "github-copilot-cli";

    package = mkOption {
      type = types.package;
      default = pkgs.nur.repos.xyenon.github-copilot-cli;
      defaultText = literalExpression "pkgs.nur.repos.xyenon.github-copilot-cli";
      description = "github-copilot-cli package to install.";
    };

    enableBashIntegration = mkEnableOption "Bash integration";

    enableZshIntegration = mkEnableOption "Zsh integration";
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs.bash.initExtra = mkIf cfg.enableBashIntegration shellIntegration;

    programs.zsh.initExtra = mkIf cfg.enableZshIntegration shellIntegration;
  };
}

