{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    let
      inherit (nixpkgs.lib) mapAttrs;

      phicomm-n1 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.allowUnsupportedSystem = true;
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            nix.registry.nixpkgs.flake = nixpkgs;
            nixpkgs.overlays = [
              (final: prev: {
                inherit (import ./pkgs { pkgs = prev; }) ubootPhicommN1;
              })
            ];
          }
          ./modules/installer/sd-image-phicomm-n1.nix
        ];
      };
    in
    with flake-utils.lib;
    (eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        legacyPackages = import ./pkgs { inherit pkgs; };
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        inherit legacyPackages;
        packages = filterPackages system (flattenTree legacyPackages);
      })) // {
      nixosModules = mapAttrs (_n: import) (import ./modules);
      images.phicomm-n1 = phicomm-n1.config.system.build.sdImage;
    };
}
