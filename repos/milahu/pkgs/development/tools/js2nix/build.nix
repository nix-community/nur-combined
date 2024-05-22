{ pkgs ?  import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/13e0d337037b3f59eccbbdf3bc1fe7b1e55c93fd.tar.gz") { } }:

let 
  js2nix = pkgs.callPackage ./default.nix { };
in {
  inherit (js2nix)
    bin 
    proxy
    node-gyp;
}
