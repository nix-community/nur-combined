let
  rev = "ac2998922b6b4b15a517f5bbbfc2a6098d2aa334";  # updated 2021-11-20
  sha256 = "1d5qcvjrn5w5fbbrf6lmf0yi4vlmdavd5x17swvwkr9lkdp70m1f";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
