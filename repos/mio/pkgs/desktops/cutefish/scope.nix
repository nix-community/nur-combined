# Rebuilds the Cutefish packages from this checkout when the NUR overlay is not
# applied, so the NixOS module can be imported on its own.
{ lib, newScope }:
lib.makeScope newScope (self: {
  mkCutefishDerivation = self.callPackage ./mk.nix { };

  cutefish-toolkit = self.callPackage ../../../by-name/cu/cutefish-toolkit/package.nix { };
  cutefish-framework = self.callPackage ../../../by-name/cu/cutefish-framework/package.nix { };
  cutefish-core = self.callPackage ../../../by-name/cu/cutefish-core/package.nix { };
  cutefish-wallpapers = self.callPackage ../../../by-name/cu/cutefish-wallpapers/package.nix { };
  cutefish-icons = self.callPackage ../../../by-name/cu/cutefish-icons/package.nix { };
  xdg-desktop-portal-cutefish =
    self.callPackage ../../../by-name/xd/xdg-desktop-portal-cutefish/package.nix
      { };
  cutefish-compositor = self.callPackage ../../../by-name/cu/cutefish-compositor/package.nix { };
  cutefish-settings = self.callPackage ../../../by-name/cu/cutefish-settings/package.nix { };
  cutefish-filemanager = self.callPackage ../../../by-name/cu/cutefish-filemanager/package.nix { };
  cutefish-terminal = self.callPackage ../../../by-name/cu/cutefish-terminal/package.nix { };
  cutefish-text-editor = self.callPackage ../../../by-name/cu/cutefish-text-editor/package.nix { };
  cutefish-video-player = self.callPackage ../../../by-name/cu/cutefish-video-player/package.nix { };
  cutefish-calendar = self.callPackage ../../../by-name/cu/cutefish-calendar/package.nix { };
  cutefish-system-monitor =
    self.callPackage ../../../by-name/cu/cutefish-system-monitor/package.nix
      { };
  cutefish-calculator = self.callPackage ../../../by-name/cu/cutefish-calculator/package.nix { };
  cutefish-qt-plugins = self.callPackage ../../../by-name/cu/cutefish-qt-plugins/package.nix { };
  cutefish-dm = self.callPackage ../../../by-name/cu/cutefish-dm/package.nix { };
})
