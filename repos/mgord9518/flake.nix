{
  description = "mgord9518's NUR repo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    systems = [
      "x86_64-linux"
      "i686-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "armv6l-linux"
      "armv7l-linux"
    ];

    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in {
    legacyPackages = forAllSystems (system: import ./default.nix {
      pkgs = import nixpkgs {
        inherit system;
      };
    });

    packages = forAllSystems (system: nixpkgs.lib.filterAttrs (
      _: v: nixpkgs.lib.isDerivation v
    ) self.legacyPackages.${system});
  };
}
