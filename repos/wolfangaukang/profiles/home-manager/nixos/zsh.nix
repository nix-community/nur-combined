{ ... }:

{
  imports = [
    ../common/zsh.nix
  ];
  #programs.zsh.initExtraBeforeCompInit = builtins.readFile ../../../zsh/config.nixos;
}
