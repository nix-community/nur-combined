{ ... }:

{
  imports = [
    ../common/tmux.nix
    ../common/zsh.nix
  ];
  programs.zsh = {
    #initExtraBeforeCompInit = builtins.readFile ../../../zsh/config;
    shellAliases = {
      nix = "nix --experimental-features 'flakes nix-command'";
    };
  };
}
