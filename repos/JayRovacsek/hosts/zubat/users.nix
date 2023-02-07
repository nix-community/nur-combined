{ config, pkgs, ... }:
let
  users = builtins.map
    (x: import ../../users/standard/${x}.nix { inherit config pkgs; }) [
      "jay"
    ];
in users
