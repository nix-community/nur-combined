{pkgs, lib, ...} @ args:
# builtins.trace "${builtins.toJSON (builtins.attrNames args)}"
{
  imports = [
    ../bootstrap/default.nix
    ../../modules/cachix/system.nix
    ../../modules/hold-gc/system.nix
  ];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 10;
  };
  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };
    cleanTmpDir = true;
  };
  environment = {
    variables.EDITOR = "nvim";
    systemPackages = with pkgs; [
      rlwrap
      wget
      curl
    ];
  };
  services = {
    irqbalance.enable = true;
  };
  cachix.enable = true;
  programs.bash = {
    shellAliases = {
      "la" = "ls -a";
      "cd.." = "cd ..";
      ".." = "cd ..";
      "simbora"="git add -A && git commit --amend && git push origin master -f";
    };
    promptInit = ''
      export EDITOR="nvim"
      export PS1="\u@\h \w \$?\\$ \[$(tput sgr0)\]"
      export PATH="$PATH:$HOME/.yarn/bin"
      mkcd(){ [ ! -z "$1" ] && mkdir -p "$1" && cd "$_"; }
      if [ -f "$HOME/.dotfilerc" ]; then
        source "$HOME/.dotfilerc"
      fi
    '';
  };
}
