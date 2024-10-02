{ lib, config, pkgs, jsonify-aws-dotfiles, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
  system = "x86_64-linux";
in
  {


    imports = [
      ./_hm-modules
      ./_roles/home-base-all.nix
      ./_roles/home-base-nixos-desktop.nix
    ];

    services.secondbrain.enable = true;

    home.packages = [
      pkgs.neovim
      pkgs.gnumake
      pkgs.gcc
      pkgs.pkg-config
      pkgs.gum
      jsonify-aws-dotfiles.packages."${system}".jsonify-aws-dotfiles
    ];

    dconf.settings = {
      "org/gnome/desktop/input-sources" = {
        #mru-sources = [ (mkTuple [ "xkb" "us" ]) ];
        per-window = false;
        sources = [ (mkTuple [ "xkb" "us" ]) ];
        xkb-options = [

          #"altwin:swap_alt_win"

          "grp:alt_shift_toggle"
          "lv3:ralt_switch"
          "compose:ralt"
          "caps:none"];
      };
    };
  }
