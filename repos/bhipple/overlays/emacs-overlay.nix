let
  rev = "90629e4e1facfacc649c667c157eb5be5dac1e59";  # updated 2021-12-05
  sha256 = "0lx0nyip1dq8pzilbyw18364ain4k9qza3dlw0lhvfvb87iz4yp5";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
