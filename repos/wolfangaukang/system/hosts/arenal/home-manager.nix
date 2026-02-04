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
        pkgs
        localLib
        ;
    };
    sharedModules = [
      inputs.sab.hmModule
      inputs.sops.homeManagerModules.sops
    ]
    ++ (with inputs.self.homeManagerModules; [
      dprint
      peaclock
    ]);
    users = localLib.importHMUsers [ "bjorn" ] hostname;
  };
}
