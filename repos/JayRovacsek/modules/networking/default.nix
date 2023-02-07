{ config, pkgs, ... }:
let
  configs = {
    aarch64-darwin = import ./aarch64-darwin.nix;
    x86_64-darwin = import ./x86_64-darwin.nix;
    aarch64-linux = import ./aarch64-linux.nix { inherit config; };
    x86_64-linux = import ./x86_64-linux.nix;
  };
in { networking = configs.${pkgs.system}; }
