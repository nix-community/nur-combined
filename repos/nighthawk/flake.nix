{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
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
        "aarch64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      treefmtEval = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        treefmt-nix.lib.evalModule pkgs ./treefmt.nix
      );
    in
    {
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
        }
      );
      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );
      overlays.default = import ./overlay.nix;
      nixosModules.overlay = {
        nixpkgs.overlays = [ (import ./overlay.nix) ];
      };
      hmModules = {
        lnshot = import ./hm-modules/lnshot.nix;
      };
      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);
      checks = forAllSystems (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });

      apps = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          prepare = {
            type = "app";
            program =
              (pkgs.writeShellScript "prepare" ''
                ${pkgs.lib.getExe self.formatter.${system}}
                nix-shell build-readme.nix
              '').outPath;
          };
          merge-master = {
            type = "app";
            program =
              (pkgs.writeShellScript "merge-master" ''
                git checkout master
                git merge staging
                git checkout staging
                git push origin master
              '').outPath;
          };
        }
      );
    };
}
