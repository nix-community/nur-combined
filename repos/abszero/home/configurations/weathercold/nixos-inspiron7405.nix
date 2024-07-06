{ self, lib, ... }:

let
  inherit (builtins) readDir;
  inherit (lib) optionalAttrs;
in

# No-op if _base.nix is hidden
optionalAttrs (readDir ./. ? "_base.nix") {
  imports = [ ../_options.nix ];

  homeConfigurations."weathercold@nixos-inspiron7405" = {
    system = "x86_64-linux";
    modules = import ./_base.nix { inherit self lib; } ++ [
      {
        specialisation = {
          hyprland-latte-pink = {
            default = true;
            configuration = {
              imports = with self.homeModules; [
                # inputs.bocchi-cursors.homeModules.bocchi-cursors-shadowBlack
                base-firefox-vertical-tabs
                base-nushell
                catppuccin-cursor
                catppuccin-fcitx5
                catppuccin-foot
                catppuccin-hyprland
              ];

              abszero.wayland.windowManager.hyprland.enable = true;

              catppuccin.accent = "pink";

              wayland.windowManager.hyprland.settings.monitor = "eDP-1, preferred, auto, 1.25";
            };
          };

          plasma6-latte-pink.configuration = {
            imports = with self.homeModules; [
              base-firefox-vertical-tabs
              base-nushell
              catppuccin-foot
              catppuccin-plasma
              colloid-fcitx5
            ];

            abszero.services.desktopManager.plasma6.enable = true;

            catppuccin.accent = "pink";
          };
        };
      }
    ];
  };
}
