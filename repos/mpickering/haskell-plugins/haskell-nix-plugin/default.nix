let
  plugin-overlay-git = builtins.fetchGit
   { url = https://github.com/mpickering/haskell-nix-plugin.git;}  ;
  plugin-overlay = import "${plugin-overlay-git}/overlay.nix";
  nixpkgs = import <nixpkgs> { overlays = [plugin-overlay]; };


  hp = nixpkgs.haskellPackages;
  plugins = nixpkgs.haskell.plugins hp;
  dump-core-plugin = plugins.dump-core;
in
  (nixpkgs.haskell.lib.addPlugin dump-core-plugin hp.either).DumpCore

