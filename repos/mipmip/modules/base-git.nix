{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git-crypt
    pre-commit
    git-lfs
    gitFull

  ];
}

