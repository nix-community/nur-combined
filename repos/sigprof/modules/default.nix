{self, ...}: let
  inherit (self.lib.modules) exportFlakeLocalModules;
in
  exportFlakeLocalModules self {
    dir = ./.;
    modules = [
      hardware/gpu/driver/nvidia
      hardware/printers/driver/hplip.nix
      hardware/sane/backend/epkowa.nix
      hardware/video
      i18n/ru_RU.nix
      nixpkgs/permitted-unfree-packages.nix
    ];
    mergedModuleName = "default";
  }
