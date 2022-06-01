let
  rev = "0b120cc825715d594fa30a180924618ab2f54137";  # updated 2022-06-01
  sha256 = "1a4q381k0irvki8yf67mzklmzw05k12w4h28cam4l67sc1acyaar";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
