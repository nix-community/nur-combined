let
  rev = "f08ca18bee73a83b3fbfd6f3caed6b8475168259";  # updated 2021-10-23
  sha256 = "11j9mx57x39gm12h3pbxkzj9mqyp13zz696v9v2y374c97yv0a2c";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
