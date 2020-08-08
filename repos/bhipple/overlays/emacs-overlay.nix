let
  rev = "082595224e09003d4ca91d3150a678264967f159";  # updated 2020-08-08
  sha256 = "14n8cqgj57swr3pb2w2sxzr52hhl41fr0qqm665v21bhgym8wra0";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
