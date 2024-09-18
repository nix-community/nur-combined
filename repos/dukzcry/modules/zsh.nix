{ config, lib, pkgs, options, ... }:

with lib;
let
  cfg = config.services.zsh;
in {
  options.services.zsh = {
    enable = mkEnableOption "zsh";
  };

  config = mkIf cfg.enable {
    programs.zsh.enable = true;
    programs.zsh.histSize = 1000000;
    programs.zsh.autosuggestions.enable = true;
    programs.zsh.syntaxHighlighting.enable = true;
    programs.zsh.setOptions = options.programs.zsh.setOptions.default ++ [ "HIST_IGNORE_ALL_DUPS" ];
    programs.zsh.interactiveShellInit = pkgs.nur.repos.dukzcry.lib.mkAfterAfter ''
      source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      bindkey "$terminfo[kcuu1]" history-substring-search-up
      bindkey "$terminfo[kcud1]" history-substring-search-down
    '';
  };
}
