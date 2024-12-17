{
  description = "pborzenkov's personal NUR repository";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
  inputs.nur.url = "github:nix-community/NUR";
  outputs = {
    self,
    nixpkgs,
    nur,
  }: let
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
    packages = forAllSystems (system:
      import ./default.nix {
        pkgs = import nixpkgs {inherit system;};
      });

    devShell = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [nur.overlays.default];
      };
    in
      pkgs.mkShell {
        packages = [
          pkgs.nix-prefetch-github
          pkgs.nix-prefetch
          pkgs.wget
          pkgs.jq
          pkgs.pnpm-lock-export
          pkgs.prefetch-yarn-deps
          pkgs.nur.repos.rycee.mozilla-addons-to-nix
        ];
      });
  };
}
