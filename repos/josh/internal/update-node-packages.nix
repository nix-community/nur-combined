# nix run --file ./internal/update-node-packages.nix
let
  flake = builtins.getFlake (builtins.getEnv "PWD");
  pkgs = import flake.inputs.nixpkgs {
    system = builtins.currentSystem;
    overlays = [ flake.overlays.default ];
  };
in
pkgs.callPackage ./pkgs/node2nix/update-script.nix { }
