{ config, lib, pkgs, ... }:

{
  environment.systemPackages =
    let
      comma = (import (pkgs.fetchFromGitHub {
        owner = "nix-community";
        repo = "comma";
        rev = "v1.3.0";
        sha256 = "rXAX14yB8v9BOG4ZsdGEedpZAnNqhQ4DtjQwzFX/TLY=";
      })).default;
    in [ comma ];
}
