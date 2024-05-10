{ inputs
, hostname
, pkgs
, localLib
, ...
}:

let
  inherit (inputs) self;
  inherit (localLib) importSystemUsers;
  hmConfig = import ./home-manager.nix { inherit inputs hostname localLib pkgs; };

in
{
  imports =
    [
      ./configuration.nix
      ./impermanence.nix
      inputs.home-manager.nixosModules.home-manager
      (hmConfig)

      "${self}/system/profiles/base.nix"
      "${self}/system/profiles/sops.nix"
    ] ++ importSystemUsers [ "bjorn" "root" ] hostname;
}
