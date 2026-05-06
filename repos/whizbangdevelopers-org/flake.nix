{
  description = "whizBANG Developers NUR packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          qepton = pkgs.callPackage ./pkgs/qepton { };
          microvm-dashboard = pkgs.callPackage ./pkgs/microvm-dashboard { };
          default = self.packages.${system}.qepton;
        }
      );

      overlays.default = final: prev: {
        qepton = final.callPackage ./pkgs/qepton { };
        microvm-dashboard = final.callPackage ./pkgs/microvm-dashboard { };
      };
    };
}
