let
  rev = "6a1e119554e8355214ce3a432ac2a6c82304ec0c";  # updated 2020-12-26
  sha256 = "0li392m2x8q6gb4wybk2v4bs7wf5rh7w4d0avnvigypvc3cdijk8";
  emacs-overlay = import (
    builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
      inherit sha256;
    }
  );
in
emacs-overlay
