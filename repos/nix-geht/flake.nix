{
  description = "vifino's Nix repository - nix geht!";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
    let
      systems = [
        "aarch64-linux" "x86_64-linux" "i686-linux"
        "aarch64-freebsd" "x86_64-freebsd" "i686-freebsd"
        "aarch64-darwin" "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (system: (import ./pkgs { inherit system; lib = nixpkgs.lib; pkgs = nixpkgsFor.${system}; }));
      nixosModules = import ./modules;
    };
}
