{
  description = "NUR repository - personal Nix packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    packagesFor = system:
      import ./default.nix {pkgs = nixpkgs.legacyPackages.${system};};
  in {
    packages = forAllSystems (
      system:
        (packagesFor system)
        // {
          default = (packagesFor system).jwt-tui;
        }
    );

    overlays.default = final: _prev:
      import ./default.nix {pkgs = final;};
  };
}
