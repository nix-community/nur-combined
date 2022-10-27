{ config, lib, pkgs, ... }:

{
  programs.zsh.enable = true;
  users = {
    groups.nixers = {
      name = "nixers";
    };
    mutableUsers = false;
    users = {
      root.initialHashedPassword = "$6$Yy0t7FdQNyWKllyp$08s6brvyIKuH7pdVi9GoUXZbOIkk3N2y4i3XbP232yV1wu7dWPhS/Ju4hCH0dUA75gi57rny2pv3HEnFbEcwg0";
      bjorn = {
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = [ "wheel" "nixers" ];
        initialHashedPassword = "$6$B2mamXY/cDsuLB8P$RepR4A9jHKPysOMj4Q3OlrSdUKuOxwpoC1.cQnA3h8opAd8eG2lzW3UZaOY3hb1TRqH4.dgpcJ4ZyAHU9fYrn/";
      };
    };
  };
  nix.settings.trusted-users = [ "@nixers" ];
}
