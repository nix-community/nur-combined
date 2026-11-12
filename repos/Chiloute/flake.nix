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

    # fetchTree instead of the src derivation: a module is not per-system, and an
    # x86_64-linux fetcher derivation cannot be built on aarch64.
    nixosModules = let
      src = (nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/vpn-tui {}).src;
    in
      import ./modules {
        vpnTuiSrc = builtins.fetchTree {
          type = "github";
          inherit (src) owner repo;
          ref = src.rev;
          narHash = src.outputHash;
        };
      };
  };
}
