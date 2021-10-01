let
  rev = "5fa26165cf34adbe693b159093ea15f24f7f7ea4";  # updated 2021-10-01
  sha256 = "137a51jmk2h9mrp959ds6n1gdgg7wmvwhjxjjd6njcs40k38rshj";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
