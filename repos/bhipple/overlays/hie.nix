let

  all-hies = import (builtins.fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};

in

self: super: {

  # All of the HIE editions that I'd like to have available in my env
  selected-hies = all-hies.selection { selector = p: { inherit (p) ghc882; }; };
}
