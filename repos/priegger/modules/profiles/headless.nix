{ config, lib, pkgs, ... }:
with lib;
let
  common = import ./common.nix { inherit config pkgs lib; };
in
recursiveUpdate common {}
