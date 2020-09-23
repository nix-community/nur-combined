{ sources ? import ./nix/sources.nix {}
, nixpkgs ? import sources.nixpkgs {}
}:
let
  gprbuild = import ./gprbuild.nix {};
in
nixpkgs.callPackage ./xmlada {
  inherit gprbuild nixpkgs sources;
}
