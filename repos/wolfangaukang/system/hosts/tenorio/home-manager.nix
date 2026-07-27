{
  inputs,
  localLib,
  pkgs,
  hostname,
  ...
}:

let
  inherit (localLib) importHMUsers;

in
{
  home-manager = {
    useGlobalPkgs = true;
    users = importHMUsers [ "bjorn" ] hostname;
    sharedModules = [
      inputs.sops.homeManagerModules.sops
    ];
    extraSpecialArgs = { inherit inputs localLib pkgs; };
  };
}
