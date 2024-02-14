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
    modules =
      import ./_base.nix { inherit self lib; }
      ++ [{
        specialisation.colloid = {
          default = true;
          configuration = {
            imports = with self.homeModules; [
              # inputs.bocchi-cursors.homeModules.bocchi-cursors-shadowBlack
              catppuccin-cursor
              colloid-fcitx5
              colloid-firefox
              colloid-fonts
              colloid-gtk
              colloid-plasma
            ];

            abszero.themes.catppuccin.accent = "pink";
          };
        };
      }];
  };
}
