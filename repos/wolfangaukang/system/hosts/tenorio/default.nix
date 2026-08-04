{
  hostname,
  inputs,
  localLib,
  pkgs,
  ...
}:

let
  inherit (inputs.home-manager.darwinModules) home-manager;
  hmConfig = import ./home-manager.nix {
    inherit
      hostname
      inputs
      localLib
      pkgs
      ;
  };

in
{
  imports = [
    ./configuration.nix
    "${inputs.self}/system/modules/personal/predicates.nix"
    home-manager
    (hmConfig)
  ]
  ++ localLib.importSystemUsers [ "bjorn" ] hostname;
}
