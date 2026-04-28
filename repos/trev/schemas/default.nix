{
  nixpkgs ? <nixpkgs>,
  lib ? nixpkgs.lib,
}:

# https://manual.determinate.systems/protocols/flake-schemas.html

let
  helpers = {
    mkChildren = children: { inherit children; };

    mkPackage = isFlakeCheck: what: system: package: {
      forSystems = [ system ];
      shortDescription = package.meta.description or "";
      derivationAttrPath = [ ];
      inherit what isFlakeCheck;
    };

    derivationsInventory =
      what: isFlakeCheck: output:
      helpers.mkChildren (
        builtins.mapAttrs (systemType: packagesForSystem: {
          forSystems = [ systemType ];
          children = builtins.mapAttrs (
            packageName: helpers.mkPackage isFlakeCheck what systemType
          ) packagesForSystem;
        }) output
      );

    try =
      e: default:
      let
        res = builtins.tryEval e;
      in
      if res.success then res.value else default;

    isSingle = set: builtins.length (builtins.attrNames set) <= 1;

    platforms = [
      "x86_64-unknown-linux-gnu"
      "x86_64-unknown-linux-musl"
      "aarch64-unknown-linux-gnu"
      "aarch64-unknown-linux-musl"
      "armv7l-unknown-linux-gnueabihf"
      "armv7l-unknown-linux-musleabihf"
      "armv6l-unknown-linux-gnueabihf"
      "armv6l-unknown-linux-musleabihf"
      "x86_64-w64-mingw32"
      "aarch64-w64-mingw32"
      "x86_64-apple-darwin"
      "arm64-apple-darwin"
    ];
  };
in

{
  appimages = import ./appimages.nix { inherit helpers lib; };
  apps = import ./apps.nix { inherit helpers; };
  bundlers = import ./bundlers.nix { inherit helpers; };
  checks = import ./checks.nix { inherit helpers; };
  devShells = import ./devShells.nix { inherit helpers; };
  formatter = import ./formatter.nix { inherit helpers; };
  images = import ./images.nix { inherit helpers lib; };
  libs = import ./libs.nix { inherit helpers; };
  nixpkgs = import ./nixpkgs.nix { inherit helpers; };
  packages = import ./packages.nix { inherit helpers lib; };
  schemas = import ./schemas.nix { inherit helpers; };
}
