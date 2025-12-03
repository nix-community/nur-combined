{
  pkgs ? import <nixpkgs> { },
}:

{
  # The `lib`, `modules`, and `overlay` names are special
  #lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./system/modules; # NixOS modules
  hmModules = import ./home/modules; # Home-manager modules
  #overlays = import ./overlays; # nixpkgs overlays
}
// (import ./pkgs { inherit pkgs; })
