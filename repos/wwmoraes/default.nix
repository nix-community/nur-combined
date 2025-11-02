{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
let
  nixpkgs = pkgs.lib.recursiveUpdate pkgs {
    lib.maintainers.wwmoraes = {
      email = "nixpkgs@artero.dev";
      github = "wwmoraes";
      githubId = 682095;
      keys = [ { fingerprint = "32B4 330B 1B66 828E 4A96  9EEB EED9 9464 5D7C 9BDE"; } ];
      matrix = "@wwmoraes:hachyderm.io";
      name = "William Artero";
    };
  };
  callPackage = nixpkgs.lib.callPackageWith (nixpkgs // self);
  self =
    rec {
      hmModules = homeManagerModules;
      homeManagerModules = import ./modules/home-manager;
      treefmtModules = import ./modules/treefmt;

      codecov-cli-bin = callPackage ./pkgs/codecov-cli-bin.nix { };
      git-credential-azure = callPackage ./pkgs/git-credential-azure.nix { };
      goutline = callPackage ./pkgs/goutline { };
      kroki = callPackage ./pkgs/kroki.nix { };
      kroki-cli = callPackage ./pkgs/kroki-cli.nix { };
      structurizr-cli = callPackage ./pkgs/structurizr-cli.nix { };
      structurizr-site-generatr = callPackage ./pkgs/structurizr-site-generatr.nix { };
      visudo = callPackage ./pkgs/visudo.nix { };
      yamlfixer = callPackage ./pkgs/yamlfixer.nix { };
    }
    // pkgs.lib.optionalAttrs pkgs.stdenvNoCC.isLinux rec {
      modules = nixosModules;
      nixosModules = import ./modules/nixos;
    }
    // pkgs.lib.optionalAttrs pkgs.stdenvNoCC.isDarwin rec {
      modules = darwinModules;
      darwinModules = import ./modules/darwin;
    };
in
self
