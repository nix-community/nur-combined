let
  rev = "2a8b1b2e9b680d7b682ff484b7d86ab00dd0c6dd";  # updated 2021-05-10
  sha256 = "17lzyyxxkkrm240gzra4pwrwmyv6dybgkx6s0rmjailhsl8yn4qq";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
