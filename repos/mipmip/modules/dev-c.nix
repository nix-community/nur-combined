{ config, lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    valgrind-light
  ];
}

