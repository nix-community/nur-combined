let
  rev = "a8af228f71353b6cc218c7b4e205c81212d5e0ef";  # updated 2021-12-02
  sha256 = "12s32ckcn1am5ipc2g336iya24fl97gzzc24ndr8z8qxbpib3qzq";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
