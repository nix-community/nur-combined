{
  description = "Personal NUR repository by mloeper";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs?rev=1042fd8b148a9105f3c0aca3a6177fd1d9360ba5";

  outputs = { self, nixpkgs, ... }:
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
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs {
          inherit system;
        };
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
      nixosModules = import ./modules;
    };
}
