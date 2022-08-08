{ pkgs, config, self, ... }:
let
  inherit (pkgs.custom.colors-lib-contrib) gtkThemeFromScheme shellThemeFromScheme;
  inherit (builtins) concatStringsSep;
  inherit (pkgs.custom) colors;
  inherit (colors.colors) base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F;
in
{
  gtk.theme = {
    package = gtkThemeFromScheme {
      scheme = colors;
    };
    name = colors.slug;
  };
  programs.bash.bashrcExtra = ''
    ${shellThemeFromScheme {
      scheme = colors;
    }}
  '';
  programs.terminator.config = {
    profiles.default = {
      background_color = "#${base00}";
      foreground_color = "#${base05}";
      cursor_color = "#${base06}";
      pallete = concatStringsSep ":" (map (i: "#${i}") [
        base00
        base08
        base0B
        base0A
        base0D
        base0E
        base0C
        base06
        "65737e"
        base08
        base0B
        base0A
        base0D
        base0E
        base0C
        base07
      ]);
      font = "Monospace 10";
      use_system_font = false;
    };
    global_config = {
      title_transmit_fg_color = "#${base05}";
      title_transmit_bg_color = "#${base02}";
      title_inactive_fg_color = "#${base01}";
      title_inactive_bg_color = "#${base00}";
    };
  };
}
