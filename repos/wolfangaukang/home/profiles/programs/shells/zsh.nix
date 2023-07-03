{ ... }:

let
  commonValues = import ./values.nix;

in {
  imports = [ ./common.nix ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" ];
      theme = "linuxonly";
    };
    sessionVariables = commonValues.sessionVariables;
    shellAliases = commonValues.shellAliases;
  };
}
