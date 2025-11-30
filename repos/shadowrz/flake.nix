{
  description = "@ShadowRZ's NUR Repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  };

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forAllSystems (
        system:
        import ./packages.nix {
          pkgs = nixpkgs.legacyPackages.${system};
          isFlake = true;
        }
      );

      nixosModules = import ./modules;
      overlays = import ./overlays;
      lib = import ./lib;
    };
}
