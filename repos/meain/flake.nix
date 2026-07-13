{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.hunk.url = "github:modem-dev/hunk/9b01f128976e2c2aa65e31c19967516260ff9b6f";
  outputs = { self, nixpkgs, hunk }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems f;
      templates = import ./templates;
      hunkFor = system:
        if hunk.packages ? ${system} then hunk.packages.${system}.default else null;
    in
    {

      legacyPackages = forAllSystems (system:
        let
          base = import ./default.nix {
            pkgs = import nixpkgs { inherit system; };
          };
          hunkPkg = hunkFor system;
        in
          if hunkPkg != null then base // { hunk = hunkPkg; } else base
      );
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});

      templates = templates.templates;
      defaultTemplate = templates.default;
    };
}
