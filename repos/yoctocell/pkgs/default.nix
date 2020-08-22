{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:

{
  # Applications
  gralc = pkgs.callPackage ./gralc { inherit sources; };
  pash = pkgs.callPackage ./pash { inherit sources; };
  terminal-typeracer = pkgs.callPackage ./terminal-typeracer { inherit sources; };
  torque = pkgs.callPackage ./torque { inherit sources; };
  tremc = pkgs.callPackage ./tremc { inherit sources; };

  # Emacs packages
  epkgs = import ./emacs-packages { inherit sources pkgs; };

  # TeX packages

}
