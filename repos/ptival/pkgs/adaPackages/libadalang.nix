{ sources ? import ./nix/sources.nix {}
, nixpkgs ? import sources.nixpkgs {}
}:
let
  gprbuild = import ./gprbuild.nix { inherit nixpkgs sources; };
in
nixpkgs.callPackage ./libadalang { inherit gprbuild nixpkgs sources; }
