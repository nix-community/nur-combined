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
    NIX_SHELL_PRESERVE_PROMPT="1";
  };
  programs.bash = {
    promptInit = ''
      export PS1='\u@\h \w $?\$ \[$(tput sgr0)\]';

      # load set-environment on shell start
      if test -f /etc/set-environment; then
        . /etc/set-environment
      fi

      # PS1 workaround for nix-shell
      if test -v IN_NIX_SHELL; then
        PS1="(shell:$IN_NIX_SHELL) $PS1"
      fi
    '';
  };
}
