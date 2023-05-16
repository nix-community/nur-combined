{ pkgs, config, self, ... }:
let
  inherit (pkgs.custom.colors-lib-contrib) gtkThemeFromScheme shellThemeFromScheme;
  inherit (pkgs.custom) colors colorpipe;
  inherit (colors.colors) base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F;
in
{
  imports = [
    ./terminator.nix
    ./telegram
    ./obsidian
    ./discord
  ];
  home.packages = with pkgs; [
    lxappearance
    colorpipe
  ];
  gtk = {
    theme = {
      package = gtkThemeFromScheme {
        scheme = colors;
      };
      name = colors.slug;
    };
    cursorTheme = {
      package = pkgs.paper-icon-theme;
      name = "Paper";
    };
    iconTheme = {
      package = pkgs.paper-icon-theme;
      name = "Paper";
    };
  };
  programs.bash.bashrcExtra = ''
    ${shellThemeFromScheme {
      scheme = colors;
    }}
  '';
}
