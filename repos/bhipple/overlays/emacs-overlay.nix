let
  rev = "5df3462dda05d8e44669cf374776274e1bc47d0a";  # updated 2021-05-23
  sha256 = "0ggmkg4shf9948wpwb0s40bjvwijvhv2wykrkayclvp419kbrfxq";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
