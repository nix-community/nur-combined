# receives: type of item looking for in modules
# returns: paths of the modules it found
let
  lsName = import <dotfiles/lib/lsName.nix>;
  loadGivenModules = import <dotfiles/lib/loadGivenModules.nix>;
  items = lsName <dotfiles/modules>;
in loadGivenModules items
