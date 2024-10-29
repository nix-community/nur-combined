{
  description = "NukDokPlex's NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = {self, ...}: let
    systems = [
      "x86_64-linux"
      "i686-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "armv6l-linux"
      "armv7l-linux"
    ];
    forAllSystems = f: self.inputs.nixpkgs.lib.genAttrs systems (system: f system);
  in {
    legacyPackages = forAllSystems (system:
      import ./default.nix {
        pkgs = import self.inputs.nixpkgs {inherit system;};
      });
    packages = forAllSystems (system: self.inputs.nixpkgs.lib.filterAttrs (_: v: self.inputs.nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
  };
}
