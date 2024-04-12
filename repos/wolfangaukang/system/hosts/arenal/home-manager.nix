{ inputs
, hostname
, pkgs
, localLib
}:

let
  inherit (localLib) importHMUsers;

in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs hostname pkgs; };
    sharedModules = [
      inputs.sab.hmModule
      inputs.impermanence.nixosModules.home-manager.impermanence
      inputs.sops.homeManagerModules.sops
    ];
    users = importHMUsers [ "bjorn" ] hostname;
  };
}
