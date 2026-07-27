{ config, lib, nixosConfig, pkgs, ... }:
let
  shellConfig = import ./shell.nix { inherit config lib pkgs; };
  stable = lib.versionOlder nixosConfig.system.nixos.release "24.05";
in
{
  home.packages = with pkgs; [
    zsh-syntax-highlighting
    nix-zsh-completions
  ];

  home.file."${config.programs.zsh.dotDir}/completion.zsh".source = ./zsh/completion.zsh;
  home.file."${config.programs.zsh.dotDir}/prompt.zsh".source = ./zsh/prompt.zsh;
  home.file."${config.programs.zsh.dotDir}/functions/j".source = ./zsh/j;

  programs = {
    direnv.enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    dotDir = ".config/zsh";
    defaultKeymap = "emacs";
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
      path = "${config.xdg.dataHome}/zsh_history";
      save = shellConfig.historySize;
      share = true;
    };
    envExtra = shellConfig.env;
    initExtra = ''
      # c.f. https://wiki.gnupg.org/AgentForwarding
      gpgconf --create-socketdir &!
      path+="$HOME/${config.programs.zsh.dotDir}/functions"
      fpath+="$HOME/.nix-profile/share/zsh/site-functions"
      fpath+="$HOME/${config.programs.zsh.dotDir}/functions"
      for func ($HOME/${config.programs.zsh.dotDir}/functions) autoload -U $func/*(x:t)
      autoload -Uz select-word-style; select-word-style bash
      if [ -e /home/vincent/.nix-profile/etc/profile.d/nix.sh ]; then . /home/vincent/.nix-profile/etc/profile.d/nix.sh; fi
      #if [ -n "$INSIDE_EMACS" ]; then
      #  chpwd() { print -P "\033AnSiTc %d" }
      #  print -P "\033AnSiTu %n"
      #  print -P "\033AnSiTc %d"
      #fi
      if [[ "$TERM" == "dumb" || "$TERM" == "emacs" ]]
      then
        TERM=eterm-color
        unsetopt zle
        unsetopt prompt_cr
        unsetopt prompt_subst
        unfunction precmd
        unfunction preexec
        PS1='$ '
        return
      fi
      # make sure navigation using emacs keybindings works on all non-alphanumerics
      # syntax highlighting
      source $HOME/${config.programs.zsh.dotDir}/plugins/zsh-nix-shell/nix-shell.plugin.zsh
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')
      ZSH_HIGHLIGHT_PATTERNS+=('rm -fR *' 'fg=white,bold,bg=red')
      ZSH_HIGHLIGHT_PATTERNS+=('rm -fr *' 'fg=white,bold,bg=red')
      source $HOME/${config.programs.zsh.dotDir}/completion.zsh
      source $HOME/${config.programs.zsh.dotDir}/plugins/powerlevel10k/powerlevel10k.zsh-theme
      source $HOME/${config.programs.zsh.dotDir}/prompt.zsh
      source $HOME/${config.programs.zsh.dotDir}/plugins/kubectl-config-switcher/kubectl-config-switcher.plugin.zsh
      setopt HIST_IGNORE_SPACE
      alias -g L="|less"
      alias -g EEL=' 2>&1 | less'
      alias -g GB='`git rev-parse --abbrev-ref HEAD`'
      alias -g GR='`git rev-parse --show-toplevel`'
      alias -s {ape,avi,flv,m4a,mkv,mov,mp3,mp4,mpeg,mpg,ogg,ogm,wav,webm}=mpv
      alias -s org=emacs
      (( $+commands[jq] )) && alias -g MJ="| jq -C '.'"  || alias -g MJ="| ${pkgs.python3}/bin/python -mjson.tool"
      (( $+functions[zshz] )) && compdef _zshz j
      [[ -n $INSIDE_EMACS ]] && \
      function ff () {
        print "\e]51;Efind-file $(readlink -f $1)\e\\"
      }
    '';
    loginExtra = ''
      if [[ -z $DISPLAY && $TTY = /dev/tty1 ]]; then
        exec sway
      fi
    '';
    profileExtra = ''
      if [ -e /home/vincent/.nix-profile/etc/profile.d/nix.sh ]; then . /home/vincent/.nix-profile/etc/profile.d/nix.sh; fi
    '';
    localVariables = {
      EMOJI_CLI_KEYBIND = "^n";
      EMOJI_CLI_USE_EMOJI = "yes";
      ZSH_HIGHLIGHT_HIGHLIGHTERS = [ "main" "brackets" "pattern" ];
    };
    sessionVariables = { RPROMPT = ""; };
    plugins = [
      {
        name = "kubectl-config-switcher";
        src = pkgs.fetchFromGitHub {
          owner = "chmouel";
          repo = "kubectl-config-switcher";
          rev = "faccc5d3c1f98170c38d3889f50fe74f3f6fe2cc";
          sha256 = "sha256-BOMvC/r6uN9Hewp8OxPIp38+V9Usp6XbMvNoDim0qmc=";
        };
      }
      {
        name = "emoji-cli";
        src = pkgs.fetchFromGitHub {
          owner = "b4b4r07";
          repo = "emoji-cli";
          rev = "0fbb2e48e07218c5a2776100a4c708b21cb06688";
          sha256 = "sha256-ii7RDTK/m+IqK7N+Xb6cEbziLPUQh7ZsbvQiX56F0sE=";
        };
      }
      {
        name = "zsh-z";
        src = pkgs.fetchFromGitHub {
          owner = "agkozak";
          repo = "zsh-z";
          rev = "aaafebcd97424c570ee247e2aeb3da30444299cd";
          sha256 = "sha256-9Wr4uZLk2CvINJilg4o72x0NEAl043lP30D3YnHk+ZA=";
        };
      }
      {
        name = "async";
        src = pkgs.fetchFromGitHub {
          owner = "mafredri";
          repo = "zsh-async";
          rev = "v1.8.5";
          sha256 = "sha256-mpXT3Hoz0ptVOgFMBCuJa0EPkqP4wZLvr81+1uHDlCc=";
        };
      }
      {
        name = "zsh-completions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-completions";
          rev = "0.34.0";
          sha256 = "sha256-qSobM4PRXjfsvoXY6ENqJGI9NEAaFFzlij6MPeTfT0o=";
        };
      }
      {
        name = "powerlevel10k";
        src = pkgs.fetchFromGitHub {
          owner = "romkatv";
          repo = "powerlevel10k";
          rev = "v1.16.1";
          sha256 = "sha256-DLiKH12oqaaVChRqY0Q5oxVjziZdW/PfnRW1fCSCbjo=";
        };
      }
      {
        name = "zsh-nix-shell";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "sha256-IT3wpfw8zhiNQsrw59lbSWYh0NQ1CUdUtFzRzHlURH0=";
        };
      }
    ];
    shellAliases = shellConfig.aliases;
  } // (if stable then {
    enableAutosuggestions = true;
  } else {
    autosuggestion.enable = true;
  });
}
