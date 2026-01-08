{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/shiroki/code/flakes"; # sets NH_OS_FLAKE variable for you
  };
}
