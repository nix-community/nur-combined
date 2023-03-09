{
  description = "pborzenkov's personal NUR repository";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
        overlays = [nur.overlay];
      };
    in
      pkgs.mkShell {
        packages = [
          pkgs.nixpkgs-fmt
          pkgs.nur.repos.rycee.mozilla-addons-to-nix
        ];
      });
  };
}
