let
  rev = "eb561e58db5ab3b52b1157da189c48a27fb7dca9";  # updated 2021-06-19
  sha256 = "10zzk0nfbncwq5gpwcqdd2p3hmkn9ldxrw85jfibcx2np3n3hbmz";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
