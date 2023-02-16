{ ... }:

let 
  commonSettings = import ./common.nix;

in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" ];
      theme = "linuxonly";
    };
    sessionVariables = commonSettings.sessionVariables; 
    shellAliases = commonSettings.shellAliases;
  };
}
