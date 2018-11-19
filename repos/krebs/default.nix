{ pkgs ? import <nixpkgs> {} }:
{
  lib = rec {
    krops = pkgs.callPackage ./submodules/krops/pkgs/krops { exec = writers.execve; inherit populate; inherit (writers) writeDash; };
    populate = pkgs.callPackage ./submodules/krops/pkgs/populate { inherit (writers) writeDash; };
    writers = pkgs.callPackage ./submodules/nix-writers {};
  };
}
