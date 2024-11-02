{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      legacyPackages = forAllSystems (system: (import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      }));
      darwinModules = {
        caddy = ./modules/darwin/caddy;
      };
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };

          lpkgs = nixpkgs.lib.filterAttrs
            (_: v: nixpkgs.lib.isDerivation v)
            self.legacyPackages.${system};

          all = pkgs.symlinkJoin {
            name = "all";
            paths = (import ./ci.nix { inherit pkgs; }).cachePkgs;
          };
        in
        (lpkgs // {
          inherit all;
          default = all;
        }));
    };
}
