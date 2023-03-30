let
  nixpkgs = builtins.getFlake github:SomeoneSerge/nixpkgs/torch20;
  pkgs = import nixpkgs {
    config.allowUnfree = true;
    config.cudaSupport = true;
    config.cudaCapabilities = [ "8.6" ];
    overlays = [ (import ./overlay.nix) ];
  };
in
pkgs.some-pkgs
