{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dots.terminal.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the terminal dotfiles module.";
  };
  options.dots.terminal.foot.enable = lib.mkEnableOption "Foot lightweight Terminal";
  options.dots.terminal.ghostty.enable = lib.mkEnableOption "Ghostty Terminal";

  config = lib.mkIf config.dots.terminal.enable {
    programs = {
      ghostty = {
        enable = config.dots.terminal.ghostty.enable;
        package = pkgs.ghostty-bin; # macos be funky
        settings = {
          font-size = 16;
          font-family = "Comic Code Ligatures";
          adjust-cell-height = "50%";
          font-thicken = true;
          font-thicken-strength = 120;
          keybind = "global:cmd+grave_accent=toggle_quick_terminal";

        };
        installVimSyntax = true;
        installBatSyntax = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
        enableBashIntegration = true;
      };
      foot = {
        enable = config.dots.terminal.foot.enable && pkgs.stdenv.isLinux;
        server.enable = true;
        settings = {
          main.dpi-aware = "yes";

          mouse.hide-when-typing = "yes";
        };
      };
    };
  };
}
