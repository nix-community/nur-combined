let
  rev = "a98e92e3c7df7137816cb96be3c4c19e291f8131";  # updated 2021-06-04
  sha256 = "1dwhclp0rrgbrfjv8l9x51jn3pl0g2w3kn9grlknp56qdjniqgh0";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
