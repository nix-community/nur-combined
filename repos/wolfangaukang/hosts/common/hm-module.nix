{ inputs, overlays, username, hostname }:

let
  inherit (inputs.nixpkgs.lib) mapAttrsToList;

in {
  home-manager = {
    extraSpecialArgs = { inherit username; };
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      inputs.sab.hmModule
      ../../modules/home-manager/personal
    ] ++ (mapAttrsToList (_: value: value) inputs.self.hmModules);
    users."${username}" = import ../${hostname}/home-manager.nix;
  };
  nixpkgs = {
    config.allowUnfree = true;
    overlays = overlays;
  };
}
