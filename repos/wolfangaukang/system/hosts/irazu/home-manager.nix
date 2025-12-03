{
  inputs,
  hostname,
  pkgs,
  localLib,
}:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit
        inputs
        hostname
        localLib
        pkgs
        ;
    };
    sharedModules = [
      inputs.sab.hmModule
      inputs.impermanence.nixosModules.home-manager.impermanence
      inputs.sops.homeManagerModules.sops
      inputs.self.homeManagerModules.peaclock
    ];
    users = localLib.importHMUsers [ "bjorn" ] hostname;
  };
}
