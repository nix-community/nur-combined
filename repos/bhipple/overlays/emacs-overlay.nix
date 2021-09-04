let
  rev = "d46a82cf4871246b01cd64740ee2cf5a24faad39";  # updated 2021-09-04
  sha256 = "16ic04ayv4di30g7myisz76pwycypd50rw03zd8r8p2ca3lbx0r9";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
