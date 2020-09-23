{ sources ? import ./nix/sources.nix {}
, nixpkgs ? import sources.nixpkgs {}
}:
let
  gprbuild-bootstrap = import ./gprbuild-bootstrap.nix {};
in
nixpkgs.callPackage ./xmlada-bootstrap {
  inherit gprbuild-bootstrap nixpkgs sources;
}
