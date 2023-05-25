{ config, pkgs, lib, materusFlake, materusPkgs, ... }:
let
  p10kcfg = "${zshcfg}/p10kcfg";
  zshcfg = "${materusFlake.path}/extraFiles/config/zsh";
  cfg = config.materus.profile.zsh;
  enableStarship = config.materus.starship.enable;
in
{
  options.materus.profile.zsh.enable = materusPkgs.lib.mkBoolOpt config.materus.profile.enableTerminalExtra "Enable materus zsh config";
  options.materus.profile.zsh.prompt = lib.mkOption {
      type = lib.types.enum ["p10k" "starship"];
      example = "p10k";
      default = "p10k";
  };


  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.ripgrep
    ];

    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      enableVteIntegration = true;
      historySubstringSearch.enable = true;
      historySubstringSearch.searchUpKey = ";5A";
      historySubstringSearch.searchDownKey = ";5B";


      envExtra = ''
        if [[ -z "$__MATERUS_HM_ZSH" ]]; then
          __MATERUS_HM_ZSH=1
        fi
        if [[ -z "$__MATERUS_HM_ZSH_PROMPT" ]]; then
          __MATERUS_HM_ZSH_PROMPT=${cfg.prompt}
        fi
      '';


      initExtraFirst = lib.mkIf (cfg.prompt == "p10k" ) ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';



      plugins = [
        (lib.mkIf (cfg.prompt == "p10k" ) {
          name = "powerlevel10k";
          src = pkgs.fetchFromGitHub {
            owner = "romkatv";
            repo = "powerlevel10k";
            rev = "bc5983543a10cff2eac30cced9208bbfd91428b8";
            sha256 = "0s8ndbpmlqakg7s7hryyi1pqij1h5dv0xv9xvr2qwwyhyj6zrx2i";
          };
          file = "powerlevel10k.zsh-theme";
        })
      ];
      
      history = {
        extended = true;
        save = 100000;
        size = 100000;
        share = false;
        ignoreDups = true;
        ignoreSpace = true;
      };


      initExtra = ''
        . ${zshcfg}/zinputrc
        source ${zshcfg}/zshcompletion.zsh
        
        bindkey -r "^["
        bindkey ";5C" forward-word
        bindkey ";5D" backward-word
        '' +
        (if (cfg.prompt == "p10k" ) then
        ''
        if zmodload zsh/terminfo && (( terminfo[colors] >= 256 )); then
          [[ ! -f ${p10kcfg}/fullcolor.zsh ]] || source ${p10kcfg}/fullcolor.zsh
        else
          [[ ! -f ${p10kcfg}/compatibility.zsh ]] || source ${p10kcfg}/compatibility.zsh
        fi
      '' else "");

    };

    programs.starship.enableZshIntegration = lib.mkForce false; 
  };


}
