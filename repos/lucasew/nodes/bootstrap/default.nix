{global, pkgs, lib, self, ...}:
let
  inherit (pkgs) vim gitMinimal tmux xclip;
  inherit (global) username;
in {
  imports = [
    ./flake-etc.nix
    ./nix.nix
    ./zerotier.nix
    ./user.nix
    ./ssh.nix
  ];
  
  boot.cleanTmpDir = true;
  i18n.defaultLocale = "pt_BR.UTF-8";
  time.timeZone = "America/Sao_Paulo";
  environment.systemPackages = [
    vim
    gitMinimal
    tmux
    xclip
  ];
  environment.variables = {
    EDITOR = "nvim";
    PS1="\\u@\\h \\w \$?\\$ \\[$(tput sgr0)\\]";
    NIX_SHELL_PRESERVE_PROMPT="1";
  };
}
