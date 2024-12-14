{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = [
      "x86_64-linux"
      "i686-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "armv6l-linux"
      "armv7l-linux"
    ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in rec {
    legacyPackages = (
      forAllSystems (
        system: (
          with {
            pkgs = import nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
              };
              overlays = [];
            };
          };
            import ./default.nix {inherit pkgs;}
        )
      )
    );
    packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
    ciJobs = let
      lib = nixpkgs.lib;
      isBuildable = platform: p: ((!p.meta.broken) && (lib.meta.availableOn {system = platform;} p));
      isCacheable = p: !(p.preferLocalBuild or false);

      filterNurAttrs = with lib;
        platform: attrs:
          filterAttrs (_: v: isDerivation v && isBuildable platform v && isCacheable v) attrs;
    in
      lib.attrsets.genAttrs systems (name: (filterNurAttrs name packages."${name}"))
      // {
        aarch64-linux = filterNurAttrs "aarch64-linux" (
          import ./default.nix {
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              crossSystem.config = "aarch64-unknown-linux-gnu";
              config.allowUnfree = true;
              overlays = [];
            };
          }
        );
      };
  };
}
