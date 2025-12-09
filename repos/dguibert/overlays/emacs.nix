final: prev:
with prev; let
  # https://gist.github.com/grahamc/2daa060dce38ad18ddfa7927e1b1a1b3
  my-texlive = texlive.combine {
    inherit
      (texlive)
      scheme-medium
      wrapfig
      capt-of
      moderncv
      biblatex
      ;
  };

  overrides = self: super: {
    org-cv = self.trivialBuild {
      pname = "org-cv";
      version = "0.0.1";
      src = fetchFromGitLab {
        owner = "Titan-C";
        repo = "org-cv";
        rev = "24bcd82348d441d95c2c80fb8ef8b5d6d4b80d95";
        sha256 = "sha256-4jXttJUkmJbWvW+A0euLDV5Mzj9Pjar/No1ETndfln0=";
      };
      buildInputs = [self.ox-hugo];
    };
  };

  # nix-env -f "<nixpkgs>" -qaP -A emacsPackages.elpaPackages
  # nix-env -f "<nixpkgs>" -qaP -A emacsPackages.melpaPackages
  # nix-env -f "<nixpkgs>" -qaP -A emacsPackages.melpaStablePackages
  # nix-env -f "<nixpkgs>" -qaP -A emacsPackages.orgPackages
  my-emacs = pkgs.emacsWithPackagesFromUsePackage {
    # Your Emacs config file. Org mode babel files are also
    # supported.
    # NB: Config files cannot contain unicode characters, since
    #     they're being parsed in nix, which lacks unicode
    #     support.
    config = ./emacs.d/emacs.org;
    # config = ./emacs.d/init.el;

    # Package is optional, defaults to pkgs.emacs
    package = pkgs.emacs-pgtk;

    alwaysEnsure = true;

    # For Org mode babel files, by default only code blocks with
    # `:tangle yes` are considered. Setting `alwaysTangle` to `true`
    # will include all code blocks missing the `:tangle` argument,
    # defaulting it to `yes`.
    # Note that this is NOT recommended unless you have something like
    # `#+PROPERTY: header-args:emacs-lisp :tangle yes` in your config,
    # which defaults `:tangle` to `yes`.
    alwaysTangle = true;

    # Optionally provide extra packages not in the configuration file.
    extraEmacsPackages = epkgs: [
      epkgs.gnus-alias
      epkgs.ol-notmuch
      # notmuch-agenda
      epkgs.cl-lib # notmuch-agenda
      epkgs.org
      epkgs.org-mime
      #epkgs.org-id
      #epkgs.org-capture
      #epkgs.ox-icalendar

      pkgs.notmuch # From main packages set
      pkgs.ripgrep

      pkgs.xclip
      pkgs.dtach # for dtache
      (pkgs.writeShellScriptBin "screenshot" ''
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" -t png "${"$"}{1--}"
      '')
    ];

    ## Optionally override derivations.
    override = epkgs:
      epkgs
      // {
        ob-async = epkgs.ob-async.overrideAttrs (o: {
          src = fetchFromGitHub {
            owner = "astahlman";
            repo = "ob-async";
            rev = "9aac486073f5c356ada20e716571be33a350a982";
            sha256 = "sha256-cIwyuwoyojc6uiNbWleh+inoRTUqMCZYQ3IydhRkEkw=";
          };
        });

        org = epkgs.org.overrideAttrs (o: {
          patches = [];
        });
      };
    #override = epkgs: epkgs // {
    #  weechat = epkgs.melpaPackages.weechat.overrideAttrs(old: {
    #    patches = [ ./weechat-el.patch ];
    #  });
    #};
  };
in {
  inherit my-texlive;
  inherit my-emacs;

  #emacsPgtkNativeComp = prev.emacsPgtkNativeComp.overrideAttrs (o: {
  #  buildInputs = o.buildInputs ++ [
  #    prev.gtk3-x11
  #  ];
  #});
  emacs-git-pgtk =
    (prev.emacs-git-pgtk.override {
      })
    .overrideAttrs (old: {
      name = "emacs-git-pgtk";
      version = inputs.emacs-src.shortRev;
      src = inputs.emacs-src;
    });
}
