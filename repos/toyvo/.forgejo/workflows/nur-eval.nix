# NUR-style repository evaluation for CI
# Based on https://github.com/nix-community/NUR/blob/master/lib/evalRepo.nix
{
  pkgs ? import <nixpkgs> { },
}:
let
  evalRepo = import ./evalRepo.nix;
in
evalRepo {
  name = "toyvo";
  url = "./.";
  src = ../../default.nix;
  inherit pkgs;
  lib = pkgs.lib;
}
