{
  description = "JuniorIsAJitterbug's nur-packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
      forEachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
      forEachPkgs = f: forEachSystem (sys: f nixpkgs.legacyPackages.${sys});
    in
    {
      packages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      });

      nixosModules = import ./modules;
      devShells = forEachPkgs (pkgs: import ./shell.nix { inherit pkgs; });
    };
}
