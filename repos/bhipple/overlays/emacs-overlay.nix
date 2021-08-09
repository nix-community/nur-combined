let
  rev = "50f1ef189623aad54410bc935e6f4b4a3aed98cf";  # updated 2021-08-08
  sha256 = "0wyn326n7q0g6xdqpw3ch5n8fv77w185nvxvyj7cblbim0ma3h1f";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
