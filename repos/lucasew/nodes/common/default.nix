{pkgs, lib, ...} @ args:
# builtins.trace "${builtins.toJSON (builtins.attrNames args)}"
{
  imports = [
    ../bootstrap/default.nix
    ../../modules/cachix/system.nix
    ../../modules/hold-gc/system.nix
  ];
  boot.loader.grub.memtest86.enable = true;
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
      unrar
      direnv
      pciutils
    ];
  };
  services = {
    irqbalance.enable = true;
    ananicy.enable = true;
  };
  cachix.enable = true;
  environment.etc."tmuxconfig".text = ''
    bind r source-file /etc/tmuxconfig; display-message "Configurações recarregadas!"

    # splitando e criando janelas no mesmo pwd de quem criou
    bind '"' split-window -c '#{pane_current_path}'
    bind % split-window -h -c '#{pane_current_path}'
    bind c new-window -c '#{pane_current_path}'

    set -g status-right-length 60
    set -g status-right "⏰ %x %k:%M 👤 #(whoami)@#(hostname) 🔋 #(cat /sys/class/power_supply/BAT1/capacity)%"
    # %x data de hoje
    set -g set-titles on

    set -g pane-border-style fg=colour0
    set -g pane-active-border-style fg=colour238
    set -g status-bg black
    set -g status-fg white

    # uso de mouse
    #set -g mouse-select-window on
    #set -g mouse-select-pane on
    #set -g mouse-resize-pane on
  '';
  programs.tmux = {
    enable = true;
    extraConfig = ''
      source-file /etc/tmuxconfig
    '';
  };
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
      eval "$(direnv hook bash)"
    '';
  };
}
