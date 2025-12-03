{
  inputs,
  hostname,
  pkgs,
  localLib,
  ...
}:

let
  profiles = localLib.getNixFiles "${inputs.self}/system/profiles/" [
    "base"
    "sops"
  ];
  users = localLib.importSystemUsers [ "bjorn" "root" ] hostname;
  hmConfig = import ./home-manager.nix {
    inherit
      inputs
      hostname
      localLib
      pkgs
      ;
  };

in
{
  imports =
    profiles
    ++ users
    ++ [
      ./configuration.nix
      ./impermanence.nix

      inputs.home-manager.nixosModules.home-manager
      hmConfig
    ];
}
