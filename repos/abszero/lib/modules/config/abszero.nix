{ lib, ... }:

let
  inherit (lib) mkEnableOption;
in

{
  options.abszero.enableExternalModulesByDefault =
    mkEnableOption "external modules exposed through `self.homeModules` and `self.nixosModules` by default when they are imported"
    // {
      default = true;
    };
}
