{
  inputs,
  hostname,
  pkgs,
  localLib,
  ...
}:

let
  hmConfig = import ./home-manager.nix {
    inherit
      inputs
      hostname
      localLib
      pkgs
      ;
  };
  profiles = localLib.getNixFiles "${inputs.self}/system/profiles/" [
    "base"
    "sops"
  ];
  users = localLib.importSystemUsers [ "bjorn" "root" ] hostname;

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
