{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];

      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
        packages = pkgs.linkFarmFromDrvs "nur-packages-check" (
          nixpkgs.lib.attrValues self.packages.${pkgs.system}
        );
      });

      legacyPackages = eachSystem (pkgs: import ./default.nix { inherit pkgs; });

      packages = eachSystem (
        pkgs:
        let
          myLib = import ./lib { inherit pkgs; };
        in
        nixpkgs.lib.filterAttrs (_: v: myLib.isBuildable v) self.legacyPackages.${pkgs.system}
      );

      apps = eachSystem (pkgs: {
        update = {
          type = "app";
          program = "${
            pkgs.writeShellApplication {
              name = "update";
              runtimeInputs = [ pkgs.nvfetcher ];
              text = "nvfetcher";
              meta.description = "Update all NUR packages using nvfetcher";
            }
          }/bin/update";
        };
      });

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nvfetcher
            nix-prefetch-git
          ];
        };
      });
    };
}
