let
  # Using NUR
  overlay = (import <nixpkgs> {}).nur.repos.mpickering.overlays.haskell-plugins;
  nixpkgs = import <nixpkgs> { overlays = [ overlay ]; };


  hp = nixpkgs.haskellPackages;
  plugins = nixpkgs.haskell.plugins hp;
  dump-core-plugin = plugins.dump-core;
in
  (nixpkgs.haskell.lib.addPlugin dump-core-plugin hp.either).DumpCore

