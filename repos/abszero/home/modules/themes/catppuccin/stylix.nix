{ config, pkgs, lib, ... }:

let
  inherit (builtins) getAttr;
  inherit (lib) mkDefault;
  inherit (config.lib.catppuccin) getVariant toTitleCase;
  cfg = config.abszero.themes.catppuccin;

  imageName =
    if cfg.accent == "magenta" || cfg.accent == "pink"
    then "nix-magenta-pink-1920x1080"
    else if cfg.accent == "blue"
    then "nix-magenta-blue-1920x1080"
    else "nix-black-4k";
  image = pkgs.catppuccin-wallpapers.override { wallpapers = [ imageName ]; }
    + "/share/wallpapers/catppuccin/${imageName}.png";
in

{
  imports = [
    ../base/stylix.nix
    ./_options.nix
  ];

  stylix = {
    base16Scheme =
      "${pkgs.base16-schemes}/share/themes/catppuccin-${getVariant}.yaml";

    cursor = {
      package =
        getAttr (getVariant + toTitleCase cfg.accent) pkgs.catppuccin-cursors;
      name = "Catppuccin-${toTitleCase getVariant}-Light";
    };

    fonts = {
      sansSerif = {
        package = pkgs.open-sans;
        name = "Open Sans";
      };
      serif = {
        # package = pkgs.noto-fonts;
        # name = "Noto Serif";
        package = pkgs.iosevka-bin.override { variant = "Etoile"; };
        name = "Iosevka Etoile";
      };
      monospace = {
        package = pkgs.iosevka-bin.override { variant = "SGr-IosevkaTerm"; };
        name = "Iosevka Term Extended";
      };
    };

    image = mkDefault image;
  };
}
