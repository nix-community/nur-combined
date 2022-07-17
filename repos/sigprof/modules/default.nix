{self, ...}: let
  inherit (self.lib.modules) exportFlakeLocalModules;
in
  exportFlakeLocalModules self {
    dir = ./.;
    modules = [
      hardware/gpu/driver/nvidia
      hardware/gpu/driver/nvidia/legacy_340.nix
      nixpkgs/permitted-unfree-packages.nix
    ];
    mergedModuleName = "default";
  }
