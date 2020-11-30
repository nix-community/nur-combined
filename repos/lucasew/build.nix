let
  globalConfig = import ./globalConfig.nix;
  nixpkgs = import globalConfig.repos.nixpkgs {};
  buildDefinitions = {
    acer-nix = nixpkgs.nixos ./nodes/acer-nix/default.nix;
  };
in buildDefinitions.acer-nix
