let
  rev = "56e595eb9a4d2ee197b9c81828afb8501d884e5e";
  sha256 = "0xhp0svr9pg4lq7rm4b3ywmc5a1x62c4sm96xly4zwp36pkycx3h";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
