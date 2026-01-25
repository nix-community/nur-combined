{
  config,
  pkgs,
  lib,
  nur,
  ...
}:

let
  inherit (lib.types) listOf path;
  cfg = config.nagy.emacs;
  emacs = (if config.services.xserver.enable then pkgs.emacs30-gtk3 else pkgs.emacs30-nox);
  emacsPackages = pkgs.emacsPackagesFor emacs;
  customEmacsPackages = emacsPackages.overrideScope (
    self: super:
    (
      nur.repos.nagy.emacsPackages # add all packages from this repository
      // {
        sotlisp = super.sotlisp.overrideAttrs {
          src = pkgs.fetchFromGitHub {
            owner = "nagy";
            repo = "speed-of-thought-lisp";
            rev = "55eb75635490ec89c0903ccc21fd5c37fdb2a8d6";
            hash = "sha256-SZH4foUlazaJwlJAYGJNw2iTTvyQ6nrs1RhxppStILI=";
          };
          preferLocalBuild = true;
          allowSubstitutes = false;
        };
        memoize = super.memoize.overrideAttrs {
          src = pkgs.fetchFromGitHub {
            owner = "nagy";
            repo = "emacs-memoize";
            rev = "985e95846b3442d0a9e87eeff2d8259ccaf0598f";
            hash = "sha256-EYq/3EPHvQSzdZ79eXONsyTcapr2CAQ6c14kHr5ug90=";
          };
          preferLocalBuild = true;
          allowSubstitutes = false;
        };
        hy-mode = super.hy-mode.overrideAttrs {
          src = pkgs.fetchFromGitHub {
            owner = "nagy";
            repo = "hy-mode";
            rev = "202b05423fe6b520c8c5d5cc1b87134bfd2c89b6";
            hash = "sha256-buDciWz8nbf0a8M2IPUZpbyQPHSugZCYDZqwSKIQqFY=";
          };
          preferLocalBuild = true;
          allowSubstitutes = false;
        };
        nix-mode = super.nix-mode.overrideAttrs (
          {
            packageRequires ? [ ],
            ...
          }:
          {
            src = pkgs.fetchFromGitHub {
              owner = "nagy";
              repo = "nix-mode";
              rev = "511b48de3f2aad8d34d029c6fa2f5aa7acf52492";
              hash = "sha256-rUzBsIA5v7xzwBq6U2VCl4cu2aP14qA9tjc46KO9enc=";
            };
            packageRequires = packageRequires ++ [ super.dash ];
            preferLocalBuild = true;
            allowSubstitutes = false;
          }
        );
        lua = super.lua.override {
          lua = pkgs.lua5_4;
          preferLocalBuild = true;
          allowSubstitutes = false;
        };
        hledger-mode = super.hledger-mode.overrideAttrs {
          src = builtins.fetchTarball "https://github.com/nagy/hledger-mode/archive/master.tar.gz";
        };
      }
    )
  );
  mkDirectoryPackagesValues =
    path: epkgs:
    (lib.attrValues (
      nur.repos.nagy.lib.emacsMakeDirectoryScope {
        inherit path epkgs;
      }
    ));
in
{
  options.nagy.emacs = {
    enable = lib.mkEnableOption "emacs config";
    packageDirectories = lib.mkOption {
      type = listOf path;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    services.emacs = {
      package = customEmacsPackages.emacs;
    };

    environment.systemPackages = [
      (customEmacsPackages.emacs.pkgs.withPackages (
        epkgs:
        [ epkgs.treesit-grammars.with-all-grammars ]
        ++ (lib.flatten (map (it: mkDirectoryPackagesValues it epkgs) cfg.packageDirectories))
      ))
    ];

    # to allow "malloc-trim" to trim memory of emacs.
    boot.kernel.sysctl."kernel.yama.ptrace_scope" = lib.mkForce 0;
  };
}
