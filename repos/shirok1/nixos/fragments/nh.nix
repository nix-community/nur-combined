{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.nh = {
    enable = true;
    flake = "/home/shiroki/code/flakes"; # sets NH_OS_FLAKE variable for you
  };
}
