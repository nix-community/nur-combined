{pkgs, ...}:
with import ../../globalConfig.nix;
{
  imports = [
    ../bootstrap/default.nix
    ../../modules/cloudflared/system.nix
    ../../modules/cachix/system.nix
    ../../modules/randomtube/system.nix
    ../../modules/vercel-ddns/system.nix
  ];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 30;
  };
  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 20;
    };
    cleanTmpDir = true;
  };
  environment.variables.EDITOR = "nvim";
  services = {
    irqbalance.enable = true;
  };
  cachix.enable = true;
  programs.bash = {
    shellAliases = {
      "la" = "ls -a";
      "sqlite3" = "${pkgs.rlwrap}/bin/rlwrap sqlite3";
      "simbora"="git add -A && git commit --amend && git push origin master -f";
    };
    promptInit = ''
      export EDITOR="nvim"
      export PS1="\u@\h \w \$?\\$ \[$(tput sgr0)\]"
      export PATH="$PATH:~/.yarn/bin/"
      source "/home/$USER/.dotfilerc" || true
    '';
  };
}
