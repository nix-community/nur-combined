{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkDefault;
  inherit (config.lib.catppuccin) toTitleCase;
  cfg = config.catppuccin;

  imageName =
    if cfg.accent == "magenta" || cfg.accent == "pink" then
      "nix-magenta-pink-1920x1080"
    else if cfg.accent == "blue" then
      "nix-magenta-blue-1920x1080"
    else
      "nix-black-4k";
  image =
    pkgs.catppuccin-wallpapers.override { wallpapers = [ imageName ]; }
    + "/share/wallpapers/catppuccin/${imageName}.png";
in

{
  imports = [
    ../base/stylix.nix
    ./catppuccin.nix
    ./fonts.nix
  ];

  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-${cfg.flavour}.yaml";

    cursor = {
      package = pkgs.catppuccin-cursors.${cfg.flavour + toTitleCase cfg.accent};
      name = "Catppuccin-${toTitleCase cfg.flavour}-Light";
    };

    fonts = {
      sansSerif = {
        package = pkgs.emptyDirectory; # font packages are in fonts.nix
        name = "Open Sans";
      };
      serif = {
        # package = pkgs.emptyDirectory;
        # name = "Noto Serif";
        package = pkgs.emptyDirectory;
        name = "Iosevka Etoile";
      };
      monospace = {
        package = pkgs.emptyDirectory;
        name = "Iosevka Term Extended";
      };
    };

    image = mkDefault image;

    # Disable targets overlapping with catppuccin/nix
    # TODO: add compat option to upstream
    targets = {
      alacritty.enable = false;
      bat.enable = false;
      btop.enable = false;
      dunst.enable = false;
      foot.enable = false;
      fzf.enable = false;
      gitui.enable = false;
      helix.enable = false;
      hyprland.enable = false;
      k9s.enable = false;
      kitty.enable = false;
      lazygit.enable = false;
      mako.enable = false;
      rofi.enable = false;
      sway.enable = false;
      swaylock.enable = false;
      tmux.enable = false;
      waybar.enable = false;
      yazi.enable = false;
      zathura.enable = false;
      zellij.enable = false;
    };
  };
}
