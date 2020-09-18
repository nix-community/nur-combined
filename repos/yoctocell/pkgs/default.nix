{ sources ? import ./nix/sources.nix
, lockFile ? builtins.fromJSON (builtins.readFile ../flake.lock)
, pkgs ? import sources.nixpkgs { }
}:
{
  gralc = pkgs.callPackage ./tools/text/gralc { inherit sources; };
  pash = pkgs.callPackage ./tools/security/pash { inherit sources; };
  terminal-typeracer = pkgs.callPackage ./applications/misc/terminal-typeracer { inherit sources; };
  torque = pkgs.callPackage ./applications/misc/torque { inherit sources; };
  tremc = pkgs.callPackage ./applications/misc/tremc { inherit sources; };

  # Emacs packages
  emacsPackages = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./applications/editors/emacs-modes {
    inherit sources;
  });
}
