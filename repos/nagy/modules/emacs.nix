{
  config,
  pkgs,
  lib,
  nur,
  ...
}:

let
  inherit (lib.types)
    listOf
    attrsOf
    path
    functionTo
    anything
    package
    ;
  cfg = config.nagy.emacs;
  emacs = if config.services.xserver.enable then pkgs.emacs31-gtk3 else pkgs.emacs31-nox;
  emacsPackages = pkgs.emacsPackagesFor emacs;
  customEmacsPackages = emacsPackages.overrideScope (
    self: super:
    (
      nur.repos.nagy.emacsPackages # add all packages from this repository
      // {

        magit = super.magit.overrideAttrs (
          {
            postPatch ? "",
            ...
          }:
          {
            # needed for magit cherry spinout
            postPatch = postPatch + ''
              substituteInPlace lisp/magit-sequence.el \
                --replace-fail 'magit-perl-executable "perl"' 'magit-perl-executable "${lib.getExe pkgs.perl}"'
            '';
          }
        );
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
          src = pkgs.fetchFromGitHub {
            owner = "nagy";
            repo = "hledger-mode";
            rev = "03b8c78d448823eade5d2a2ae08d150d00146263";
            hash = "sha256-G9IHDhy1kdmnusHUQR0F4kLs2DUrawgxDnhloZvV7FM=";
          };
          preferLocalBuild = true;
          allowSubstitutes = false;
        };

        crate =
          pkgs.callPackage (builtins.fetchTarball "https://github.com/nagy/crate.el/archive/master.tar.gz")
            {
              emacsPackages = super;
            };

        nixos =
          pkgs.callPackage (builtins.fetchTarball "https://github.com/nagy/nixos.el/archive/master.tar.gz")
            {
              emacsPackages = super;
            };

        org-jxl-images =
          pkgs.callPackage
            (builtins.fetchTarball "https://github.com/nagy/org-jxl-images/archive/master.tar.gz")
            {
              emacsPackages = super;
            };
      }
      // (builtins.mapAttrs (_name: f: f self super) cfg.extraOverrides)
    )
  );
  mkDirectoryPackagesValues =
    paths: epkgs:
    (lib.attrValues (
      nur.repos.nagy.lib.emacsMakeDirectoryScope {
        inherit paths epkgs;
      }
    ));
in
{
  options.nagy.emacs = {

    packageDirectories = lib.mkOption {
      type = listOf path;
      default = [ ];
    };

    extraOverrides = lib.mkOption {
      type = attrsOf anything;
      default = { };
      example = lib.literalExpression ''
        {
          magit = self: super: super.magit.overrideAttrs (old: {
            src = pkgs.fetchFromGitHub { ... };
          });
          foo-package = self: super: import ~/foo-package {
            emacsPackages = self;
          };
        }
      '';
      description = ''
        Extra Emacs package overrides.  Each value is a function
        `self: super: derivation`.  Merges across modules.
      '';
    };

    extraPackages = lib.mkOption {
      type = functionTo (listOf package);
      default = epkgs: [ ];
      example = lib.literalExpression ''
        epkgs: [
          epkgs.magit
          (epkgs.callPackage ./my-local-pkg { })
        ]
      '';
      description = ''
        Extra Emacs packages.  Receives `epkgs`, returns a list of
        derivations.  Lists from multiple modules are concatenated.
      '';
    };

  };

  config = {
    services.emacs = {
      package = customEmacsPackages.emacs;
    };

    environment.systemPackages = [
      (customEmacsPackages.emacs.pkgs.withPackages (
        epkgs:
        [
          epkgs.treesit-grammars.with-all-grammars
        ]
        ++ (cfg.extraPackages epkgs)
        ++ (mkDirectoryPackagesValues cfg.packageDirectories epkgs)
      ))
      # perl # needed for magit cherry spinout
    ];

    # # # to allow "malloc-trim" to trim memory of emacs.
    # # # somehow it seems to work without this now.
    # (malloc-trim 0) returns nil without this. It should rather return t.
    # boot.kernel.sysctl."kernel.yama.ptrace_scope" = lib.mkForce 0;
    # at runtime: sudo sysctl -w kernel.yama.ptrace_scope=0

    # maybe only needed for remote systems
    environment.sessionVariables.TERMINFO_DIRS = [
      "${pkgs.emacs.pkgs.ghostel}/share/emacs/site-lisp/elpa/ghostel-${pkgs.emacs.pkgs.ghostel.version}/etc/terminfo"
    ];
  };
}
