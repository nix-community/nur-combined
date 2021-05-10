let
  rev = "bc8e1043d397d60bee01b810b9e53100b4f44344";  # updated 2021-05-03
  sha256 = "1mvpcg3wiai9f87sg1aywir90p0kcy3ipl7wbpl6nhb5cwsyqs30";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
