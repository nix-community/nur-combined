{ config, lib, ... }:
let
  cfg = config.my.home.pager;
in
{
  options.my.home.pager = with lib.my; {
    enable = mkDisableOption "pager configuration";
  };


  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      # My default pager
      PAGER = "less";
      # Clear the screen on start and exit
      LESS = "-R -+X -c";
    };

    programs.zsh.localVariables = {
      # Colored man pages
      LESS_TERMCAP_mb = "$(tput bold; tput setaf 2)";
      LESS_TERMCAP_md = "$(tput bold; tput setaf 6)";
      LESS_TERMCAP_me = "$(tput sgr0)";
      LESS_TERMCAP_so = "$(tput bold; tput setaf 3; tput setab 4)";
      LESS_TERMCAP_se = "$(tput rmso; tput sgr0)";
      LESS_TERMCAP_us = "$(tput bold; tput setaf 2)";
      LESS_TERMCAP_ue = "$(tput rmul; tput sgr0)";
      LESS_TERMCAP_mr = "$(tput rev)";
      LESS_TERMCAP_mh = "$(tput dim)";
      LESS_TERMCAP_ZN = "$(tput ssubm)";
      LESS_TERMCAP_ZV = "$(tput rsubm)";
      LESS_TERMCAP_ZO = "$(tput ssupm)";
      LESS_TERMCAP_ZW = "$(tput rsupm)";
    };
  };
}
