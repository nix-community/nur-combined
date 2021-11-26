let
  rev = "bd4015e47bec7c53977f7db377d204dcb593c43d";  # updated 2021-11-07
  sha256 = "10nvdrzplpwqwa4z5c5kg2a6rwpna1x238sas2apdr4snvn7nf2l";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
