{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  outputs = {
    self,
    nixpkgs,
  }: let
    systems = [
      "x86_64-linux"
      # "i686-linux"
      "aarch64-linux"
      # "armv6l-linux"
      # "armv7l-linux"
      "riscv64-linux"

      # "x86_64-darwin"
      "aarch64-darwin"
    ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in {
    legacyPackages = forAllSystems (system:
      import ./default.nix {
        pkgs = import nixpkgs {inherit system;};
      });
    packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
  };
}
