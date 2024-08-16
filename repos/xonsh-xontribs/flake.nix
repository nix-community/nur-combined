{
  description = "[how-to use in nix](https://github.com/drmikecrowe/nur-packages) Community Xonsh Xontrib NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = {
    self,
    nixpkgs,
  }: let
    systems = [
      "x86_64-linux"
      "i686-linux"
      "x86_64-darwin"
      "aarch64-darwin"
      "aarch64-linux"
      "armv6l-linux"
      "armv7l-linux"
    ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in {
    legacyPackages = forAllSystems (system:
      import ./default.nix {
        pkgs = import nixpkgs {inherit system;};
      });
    packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
    overlays = import ./overlay.nix;
    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        name = "flakeShell-${system}";
        buildInputs = with pkgs; [
          git
          alejandra
          statix
          nix-prefetch
          nix-prefetch-scripts
          nix-prefetch-github
          nix-tree
          ripgrep
        ];
      };
    });
  };
}
