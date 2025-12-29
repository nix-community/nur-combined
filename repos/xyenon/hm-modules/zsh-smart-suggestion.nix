{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.zsh.smart-suggestion;
in
{
  options.programs.zsh.smart-suggestion = {
    enable = lib.mkEnableOption "zsh smart-suggestion (AI-powered command suggestions)";

    package = lib.mkPackageOption pkgs.nur.repos.xyenon "zsh-smart-suggestion" { };

    configFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = lib.literalExpression "./smart-suggestion-config.zsh";
      description = ''
        Path to a custom configuration file that will be linked to
        {file}`~/.config/smart-suggestion/config.zsh`.
      '';
    };
  };

  config = lib.mkIf (config.programs.zsh.enable && cfg.enable) {
    programs.zsh = {
      autosuggestion.enable = true;
      initContent = lib.mkOrder 750 ''
        SMART_SUGGESTION_BINARY="${cfg.package}/bin/smart-suggestion"
        source "${cfg.package}/share/zsh/plugins/zsh-smart-suggestion/smart-suggestion.plugin.zsh"
      '';
    };

    xdg.configFile."smart-suggestion/config.zsh" = lib.mkIf (cfg.configFile != null) {
      source = cfg.configFile;
    };
  };
}
