{
  description = "NUR repository - personal Nix packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    # modules is not a package: keep only derivations available on this system
    packagesFor = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      nixpkgs.lib.filterAttrs (_: p: nixpkgs.lib.isDerivation p && nixpkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform p)
      (import ./default.nix {inherit pkgs;});
  in {
    packages = forAllSystems (
      system:
        (packagesFor system)
        // {
          default = (packagesFor system).jwt-tui;
        }
    );

    overlays.default = final: _prev:
      removeAttrs (import ./default.nix {pkgs = final;}) ["modules"];

    nixosModules = import ./modules;
  };
}
