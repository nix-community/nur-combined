# Rebuilds the Cutefish packages from this checkout when the NUR overlay is not
# applied, so the NixOS module can be imported on its own.
{ lib, newScope }:
lib.makeScope newScope (
  self:
  let
    packages = {
      cutefish-toolkit = self.callPackage ../cutefish-toolkit/package.nix { };
      cutefish-framework = self.callPackage ../cutefish-framework/package.nix { };
      cutefish-core = self.callPackage ../cutefish-core/package.nix { };
      cutefish-wallpapers = self.callPackage ../cutefish-wallpapers/package.nix { };
      cutefish-icons = self.callPackage ../cutefish-icons/package.nix { };
      xdg-desktop-portal-cutefish = self.callPackage ../../xd/xdg-desktop-portal-cutefish/package.nix { };
      cutefish-compositor = self.callPackage ../cutefish-compositor/package.nix { };
      cutefish-settings = self.callPackage ../cutefish-settings/package.nix { };
      cutefish-filemanager = self.callPackage ../cutefish-filemanager/package.nix { };
      cutefish-terminal = self.callPackage ../cutefish-terminal/package.nix { };
      cutefish-text-editor = self.callPackage ../cutefish-text-editor/package.nix { };
      cutefish-video-player = self.callPackage ../cutefish-video-player/package.nix { };
      cutefish-calendar = self.callPackage ../cutefish-calendar/package.nix { };
      cutefish-system-monitor = self.callPackage ../cutefish-system-monitor/package.nix { };
      cutefish-calculator = self.callPackage ../cutefish-calculator/package.nix { };
      cutefish-qt-plugins = self.callPackage ../cutefish-qt-plugins/package.nix { };
      cutefish-dm = self.callPackage ../cutefish-dm/package.nix { };
    };
  in
  packages // (import ./groups.nix packages)
)
