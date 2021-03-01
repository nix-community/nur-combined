let
  rev = "0bcbe96bef50e3c059a4792f8a227c42b299cc2a";  # updated 2021-02-28
  sha256 = "1vfwbb1xiq8vhp23w1sr2p5bvbpyi0bfymrz0yw5szcnzwl73dws";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
