{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        # "i686-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"

        # "armv6l-linux"
        # "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      overlay = final: prev: {
        septimalmind = import ./default.nix {
          pkgs = prev;
        };
      };
    in
    rec {
      # legacyPackages = forAllSystems (system: import ./default.nix {
      #   pkgs = import nixpkgs { inherit system; };
      # });
      # packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});

      overlays = {
        default = overlay;
      };
      modules.nixos.default = {
        nixpkgs.overlays = [ overlay ];
      };
      modules.darwin.default = modules.nixos.septimalmind;
    };
}
