self: super:
with super.lib;
let
  modules = import <dotfiles/lib/listModules.nix> "overlay";
  importedModules = map (import) modules;
in foldl' (flip extends) (_: super) importedModules self
