let
  plugin-overlay-git = builtins.fetchGit
   { url = https://github.com/mpickering/haskell-nix-plugin.git;}  ;
  plugin-overlay = import "${plugin-overlay-git}/overlay.nix";
  nixpkgs = import <nixpkgs> { overlays = [plugin-overlay]; };

  hl = nixpkgs.haskell.lib;
  hp = nixpkgs.haskellPackages;
in
  (hp.withPlugin(plugs: ps: hl.addPlugin plugs.dump-core ps.either)).DumpCore

