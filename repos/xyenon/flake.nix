{
  description = "My personal NUR repository";
  nixConfig = {
    extra-substituters = [ "https://nur-xyenon.cachix.org" ];
    extra-trusted-public-keys = [
      "nur-xyenon.cachix.org-1:fZ3SGJ3E1p34JSG5j4etfF9+vjJGMZxe1dDBNliKx5U="
    ];
  };
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems f;
    in
    {
      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.nixfmt-rfc-style
      );
      legacyPackages = forAllSystems (
        system: import ./default.nix { pkgs = import nixpkgs { inherit system; }; }
      );
      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );
      nixosModules = import ./modules;
      hmModules = import ./hm-modules;
      overlays = import ./overlays;
    };
}
