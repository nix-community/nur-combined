{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.dotfiles.zsh;
in {
  options.dotfiles.zsh = {
    enable = mkEnableOption "Configure zsh in home manager";
  };

  config = mkIf cfg.enable {
    # Installs p10k theme
    home.packages = with pkgs; [
      eza
      bat
      zsh-powerlevel10k
      nerdfonts
    ];

    fonts.fontconfig.enable = true;

    programs.zsh = {
      enable = true;
      autocd = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      initExtra = ''
        zstyle ':completion:*' menu select
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
        if [[ $TERM = "xterm-256color" ]]; then
            source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
            source ~/.p10k.zsh
        fi
      '';

      cdpath = [
        "/etc/nixos"
      ];

      shellAliases = {
        cat = "bat --paging=never";
        less = "bat";
        ls = "exa -lh --octal-permissions --no-permissions --group  -F";
      };
    };
  };
}
