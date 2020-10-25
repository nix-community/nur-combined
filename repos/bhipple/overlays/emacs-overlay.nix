let
  rev = "7b5dea6b1493fd3b065878364f0bfc5aa4363306";  # updated 2020-10-25
  sha256 = "1whnlgh54isvz6c636y01crpg3hc289pd8rfwj9b7l2dnxidp6w2";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
