{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
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
      assert nixpkgs.legacyPackages.x86_64-linux ? writeShellApplication;
    {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = nixpkgs.legacyPackages."${system}";
      });
      packages = self.legacyPackages;
        #forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
      lib = self.packages."${builtins.currentSystem}".lib;
    };
}
