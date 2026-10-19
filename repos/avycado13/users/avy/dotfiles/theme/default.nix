{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dots.theme.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the theme dotfiles module.";
  };

  config = lib.mkIf config.dots.theme.enable {
    catppuccin = {
      autoEnable = true;
      enable = true;
      flavor = "mocha";
      vscode = {
        profiles.default = {
          accent = "mauve";
          settings = {
            boldKeywords = true;
            italicComments = true;
            italicKeywords = true;
            colorOverrides = { };
            customUIColors = { };
            workbenchMode = "default";
            bracketMode = "rainbow";
            extraBordersEnabled = false;
          };
        };
      };
    };
    # The upstream theme's rainbow array is not a valid style in Helix 25.07.
    xdg.configFile."helix/themes/catppuccin-mocha.toml".source = lib.mkForce (
      pkgs.runCommand "catppuccin-helix-mocha" { } ''
        ${pkgs.gnused}/bin/sed '/^rainbow = /d' \
          ${config.catppuccin.sources.helix}/default/catppuccin_mocha.toml > "$out"
      ''
    );
    fonts.fontconfig.enable = true;
    home.packages = [
      pkgs.nerd-fonts.jetbrains-mono
    ];
  };
}
