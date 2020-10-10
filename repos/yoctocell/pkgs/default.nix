{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs { }
}:
rec
{

  bottom = pkgs.callPackage ./tools/system/bottom { inherit sources; };
  gralc = pkgs.callPackage ./tools/text/gralc { inherit sources; };
  # nyxt = pkgs.callPackage ./applications/networking/browsers/nyxt { inherit sources; };
  pash = pkgs.callPackage ./tools/security/pash { inherit sources; };
  terminal-typeracer = pkgs.callPackage ./applications/misc/terminal-typeracer { inherit sources; };
  torque = pkgs.callPackage ./applications/misc/torque { inherit sources; };
  tremc = pkgs.callPackage ./applications/misc/tremc { inherit sources; };
  git-get = pkgs.callPackage ./applications/version-management/git-get { inherit sources; };
  git-filter-repo = pkgs.python3.pkgs.callPackage ./applications/version-management/git-filter-repo { };
  git-privacy = pkgs.python3.pkgs.callPackage ./applications/version-management/git-privacy {
    inherit git-filter-repo;
  };

  # Emacs packages
  emacsPackages = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./applications/editors/emacs-modes {
    inherit sources;
  });
}
