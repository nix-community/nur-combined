{
  description = "An experimental NUR repository";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs?ref=nixos-unstable"; };
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
      ];
    in
    {
      packages = nixpkgs.lib.genAttrs systems (system: (import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      }).packages);
    };
}
