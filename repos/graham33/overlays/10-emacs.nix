let
  rev = "977c17ecfb8c022f8429e569c44c64fa85c96246";  # updated 2021-07-15
  sha256 = "0mvlgjl23zaqc0dbxfwlkdjw93bsdxp5ni7zwdwfzspq5jlmagln";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
