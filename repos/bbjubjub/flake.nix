{
  description = "My humble additions to the NUR";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";

  outputs = inputs @ {flake-parts, ...}: let
    inherit (inputs.nixpkgs) lib;
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.hercules-ci-effects.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];

      herculesCI.ciSystems = ["x86_64-linux" "aarch64-linux"];

      hercules-ci.flake-update.enable = true;
      hercules-ci.flake-update.when.dayOfWeek = "Sat";

      perSystem = {
        pkgs,
        system,
        inputs',
        self',
        ...
      }: {
        legacyPackages = import ./default.nix {
          pkgs = inputs'.nixpkgs.legacyPackages;
        };
        packages = lib.filterAttrs (_: v: lib.isDerivation v) self'.legacyPackages;
      };
    };
}
