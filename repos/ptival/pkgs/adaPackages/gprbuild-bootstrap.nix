{ sources ? import ./nix/sources.nix {}
, nixpkgs ? import sources.nixpkgs {}
}:
let
  gprconfig_kb-source = import ./gprconfig_kb-source.nix { inherit nixpkgs sources; };
  xmlada-source = import ./xmlada-source.nix { inherit nixpkgs sources; };
in
nixpkgs.callPackage ./gprbuild-bootstrap {
  inherit gprconfig_kb-source nixpkgs sources xmlada-source;
}
