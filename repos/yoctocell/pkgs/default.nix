{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs { }
}:
{

  bottom = pkgs.callPackage ./tools/system/bottom { inherit sources; };
  gralc = pkgs.callPackage ./tools/text/gralc { inherit sources; };
  nyxt = pkgs.callPackage ./applications/networking/browsers/nyxt { inherit sources; };
  pash = pkgs.callPackage ./tools/security/pash { inherit sources; };
  terminal-typeracer = pkgs.callPackage ./applications/misc/terminal-typeracer { inherit sources; };
  torque = pkgs.callPackage ./applications/misc/torque { inherit sources; };
  tremc = pkgs.callPackage ./applications/misc/tremc { inherit sources; };

  # Emacs packages
  emacsPackages = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./applications/editors/emacs-modes {
    inherit sources;
  });
}
