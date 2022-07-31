{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  # NOTE: I want to use a release but I notice it's nix*os* specifically.
  # There is no nixpkgs-22.05. Is that a problem? Original link:
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
      packages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      });
    };
}
