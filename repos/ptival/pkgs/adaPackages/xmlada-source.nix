{ sources ? import ./nix/sources.nix {}
, nixpkgs ? import sources.nixpkgs {}
}:
nixpkgs.callPackage ./xmlada-source { inherit nixpkgs sources; }
