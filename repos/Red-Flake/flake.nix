{
  description = "Red-Flake's NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      # Per-system package sets
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
        }
      );

      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );

      # NixOS modules (not per-system)
      nixosModules = {
        # expose a bundle if your ./modules/default.nix aggregates modules
        default = import ./modules;
      };

      # Overlays (not per-system). At minimum export a `default` overlay function.
      #overlays = [ (import ./overlays) ];
    };
}
