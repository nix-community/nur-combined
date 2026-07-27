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
    historySubstringSearch.enable = true;
    shellAliases = terminalSettings.shellAliases;
    initContent = ''
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z} r:|[._-]=* r:|=*'
    '';
  };
}
