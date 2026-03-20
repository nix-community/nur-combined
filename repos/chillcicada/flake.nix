{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        treefmt-nix.flakeModule
      ];
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      flake = {
        modulePackages.ngbe = ./pkgs/ngbe;
        nixosModules.default = ./modules/nixos;
        overlays.default =
          _: super:
          super.lib.packagesFromDirectoryRecursive {
            inherit (super) callPackage;
            directory = ./pkgs;
          };
      };
      perSystem =
        { system, pkgs, ... }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ self.overlays.default ];
          };

          packages = {
            inherit (pkgs)
              aidoku-cli
              cronet-go
              feishu-darwin
              gallant
              imunes
              kodama
              mccgdi
              naiveproxy
              qqmusic-darwin
              rime-wubi98
              rindex
              shanghaitech-mirror-frontend
              sing-box-app
              sing-box-app-beta
              sing-box-beta
              vips_8_14_5
              wubi98-fonts
              ;
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
          };
        };
    };
  # let
  #   systems = [
  #     "x86_64-linux"
  #     "aarch64-linux"
  #     "x86_64-darwin"
  #     "aarch64-darwin"
  #   ];
  #   forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  # in
  # {
  #   overlays.default = _final: prev: {
  #     chillcicada = self.packages."${prev.stdenv.hostPlatform.system}";
  #   };

  #   legacyPackages = forAllSystems (
  #     system:
  #     import ./default.nix {
  #       pkgs = import nixpkgs {
  #         inherit system;
  #         config.allowUnfree = true;
  #       };
  #     }
  #   );

  #   packages = forAllSystems (
  #     system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
  #   );

  #   treefmt = {
  #     projectRootFile = "flake.nix";
  #     programs.nixfmt.enable = true;
  #   };
  # };
}
