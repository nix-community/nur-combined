{self, ...}: let
  inherit (self.lib.modules) exportFlakeLocalModules;
in
  exportFlakeLocalModules self {
    dir = ./.;
    modules = [
      hardware/gpu/driver/nvidia
      hardware/gpu/driver/nvidia/legacy_340.nix
      hardware/printers/driver/hplip.nix
      hardware/sane/backend/epkowa.nix
      i18n/ru_RU.nix
      nixpkgs/permitted-unfree-packages.nix
    ];
    mergedModuleName = "default";
  }
