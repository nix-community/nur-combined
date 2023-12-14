{ pkgs, ...}:

let
  ini = pkgs.formats.ini {};

  inherit (pkgs.custom.colors.colors) base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F;

  colorscheme-file = ini.generate "base16-colorscheme.conf" {
    
    ColorScheme = {
      active_colors = builtins.concatStringsSep ", " [
        "#ff${base0C}"
        "#ff${base01}"
        "#ff${base01}"
        "#ff${base05}"
        "#ff${base03}"
        "#ff${base04}"
        "#ff${base0E}"
        "#ff${base06}"
        "#ff${base05}"
        "#ff${base01}"
        "#ff${base00}"
        "#ff${base03}"
        "#ff${base02}"
        "#ff${base0E}"
        "#ff${base09}"
        "#ff${base08}"
        "#ff${base02}"
        "#ff${base05}"
        "#ff${base01}"
        "#ff${base0E}"
        "#8f${base0E}"
      ];
      disabled_colors = builtins.concatStringsSep ", " [
        "#ff${base0F}"
        "#ff${base01}"
        "#ff${base01}"
        "#ff${base05}"
        "#ff${base03}"
        "#ff${base04}"
        "#ff${base0F}"
        "#ff${base0F}"
        "#ff${base0F}"
        "#ff${base01}"
        "#ff${base00}"
        "#ff${base03}"
        "#ff${base02}"
        "#ff${base0E}"
        "#ff${base09}"
        "#ff${base08}"
        "#ff${base02}"
        "#ff${base05}"
        "#ff${base01}"
        "#ff${base0F}"
        "#8f${base0F}"
    ];
    inactive_colors = builtins.concatStringsSep ", " [
      "#ff${base0C}"
      "#ff${base01}"
      "#ff${base01}"
      "#ff${base05}"
      "#ff${base03}"
      "#ff${base04}"
      "#ff${base0E}"
      "#ff${base06}"
      "#ff${base05}"
      "#ff${base01}"
      "#ff${base00}"
      "#ff${base03}"
      "#ff${base02}"
      "#ff${base0E}"
      "#ff${base09}"
      "#ff${base08}"
      "#ff${base02}"
      "#ff${base05}"
      "#ff${base01}"
      "#ff${base0E}"
      "#8f${base0E}"
    ];
  };
};
in {
  xdg.configFile."qt5ct/qt5ct.conf".source = ini.generate "qt5ct.conf" {
    Appearance = {
      custom_pallete = true;
      color_scheme_path = colorscheme-file;
    };
  };
}
