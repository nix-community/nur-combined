let
  rev = "12aefa1afc9300124a711e89cd6fd951dc8e9c44";  # updated 2021-07-10
  sha256 = "09xc4l578j5iwrjysr1wmm48fydl9zijmg5i1xvjd4fb25423np2";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
