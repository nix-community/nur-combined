let
  self = builtins.getFlake ./.;
  nixpkgs = self.inputs.nixpkgs;
  pkgs = import nixpkgs {
    config.allowUnfree = true;
    config.cudaSupport = true;
    config.cudaCapabilities = [ "8.6" ];
    overlays = [ (import ./overlay.nix) ];
  };
in
pkgs.some-pkgs
