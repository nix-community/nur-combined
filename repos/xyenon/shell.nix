{
  system ? builtins.currentSystem,
  nixpkgs ? <nixpkgs>,
}:

import "${nixpkgs}/shell.nix" { inherit system nixpkgs; }
