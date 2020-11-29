{ config, pkgs, ... }:

{
  nix.package = let
    nix_src = builtins.fetchGit https://github.com/dtzWill/nix;
    nix_release = import (nix_src + "/release.nix") {
      nix = nix_src;
      #nixpkgs = fetchTarball channel:nixos-unstable;
      nixpkgs = <nixpkgs>;
    };
  in
    nix_release.build.x86_64-linux; # // { perl-bindings = nix_release.perlBindings.x86_64-linux; };
}
