{ config, pkgs, ... }:

let
  user = "nixos";

in {
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "20.09";
  };

  defaultajAgordoj.cli.enable = true;
}  
