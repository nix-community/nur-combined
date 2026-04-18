{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
          final: prev:
          prev.lib.packagesFromDirectoryRecursive {
            inherit (final) callPackage;
            directory = ./pkgs;
          };
      };
      perSystem =
        {
          system,
          config,
          lib,
          pkgs,
          ...
        }:
        let
          filterAvailable = lib.filterAttrs (_: lib.meta.availableOn { inherit system; });
        in
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ self.overlays.default ];
          };

          checks =
            filterAvailable {
              ngbe = pkgs.linuxPackages.callPackage self.modulePackages.ngbe { };
            }
            // config.packages;

          packages = filterAvailable {
            inherit (pkgs)
              aidoku-cli
              anytype-darwin
              cronet-go
              feishu-darwin
              gallant
              imunes
              kodama
              ltspice-darwin
              mccgdi
              naiveproxy
              qqmusic-darwin
              rime-wubi98
              rindex
              shanghaitech-mirror-frontend
              sing-box-app
              sing-box-app-beta
              sing-box-beta
              termius-app
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
}
