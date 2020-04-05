let
  rev = "d88e11b86f3d7c81ca1f6fd555a01812a260d0e8";
  sha256 = "037w0rzk4dilcb1n92z4kg1bqpw5d8fnmq3vbm30z9nwpd258a0r";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
