{
  osConfig,
  inputs,
  pkgs,
  ...
}:

let
  terminalSettings = import "${inputs.self}/home/users/bjorn/settings/terminal.nix" { inherit pkgs; };

in
{
  programs.zsh = {
    enable = osConfig.programs.zsh.enable;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
      ];
      theme = "linuxonly";
    };
    shellAliases = terminalSettings.shellAliases;
  };
}
