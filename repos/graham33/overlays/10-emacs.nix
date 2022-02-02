let
  rev = "2724a0a09fbb95110980085991cc05fb45ee6c2b";  # updated 2022-02-02
  sha256 = "142l8jsi9qjczkca6aiw8jrmbgbn9r2330rsibgns4648lyw07kc";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
