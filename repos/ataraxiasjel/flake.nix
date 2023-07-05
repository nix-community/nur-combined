{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
    in
    {
      packages = forAllSystems (system: import ./pkgs/default.nix {
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
      });
      overlays = import ./overlays;
    };

  nixConfig = {
    extra-substituters = ["https://ataraxiadev-foss.cachix.org"];
    extra-trusted-public-keys = ["ataraxiadev-foss.cachix.org-1:ws/jmPRUF5R8TkirnV1b525lP9F/uTBsz2KraV61058="];
  };
}
