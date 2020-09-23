{ sources ? import ./nix/sources.nix {}
, nixpkgs ? import sources.nixpkgs {}
}:
nixpkgs.callPackage ./gprconfig_kb-source { inherit nixpkgs sources; }
