{ lib, ... }:

let
  inherit (lib) mkDefault;
in

{
  imports = [ ./catppuccin.nix ];

  catppuccin.pointerCursor.enable = true;
  home.pointerCursor = {
    gtk.enable = mkDefault true;
    x11.enable = mkDefault true;
  };
}
