let
  rev = "e3e97b8cd1c8db6fb5bf43ded3dc85a84e732a7a";  # updated 2021-08-15
  sha256 = "07bypbbgkjpqx6f4ay7a0n8qnrdys59k64q15smcbqjrf9bmnkg4";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
