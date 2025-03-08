{ inputs
, hostname
, pkgs
, localLib
}:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs hostname pkgs localLib; };
    sharedModules = [
      inputs.sab.hmModule
      inputs.impermanence.nixosModules.home-manager.impermanence
      inputs.sops.homeManagerModules.sops
    ];
    users = localLib.importHMUsers [ "bjorn" ] hostname;
  };
}
