{ pkgs, ... }:

let
  commonValues = import ./values.nix;

in {
  imports = [ ./common.nix ];

  programs.fish = {
    enable = true;
    shellAliases = commonValues.shellAliases;
  };
  home.sessionVariables = commonValues.sessionVariables;
}
