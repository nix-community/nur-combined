{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.zsh;
in
{
  options = {
    profiles.zsh = {
      enable = mkOption {
        default = true;
        description = "Enable zsh profile and configuration";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        zsh-syntax-highlighting
        nix-zsh-completions
      ];
      home.file."${config.programs.zsh.dotDir}/completion.zsh".source = ./assets/zsh/completion.zsh;
      home.file."${config.programs.zsh.dotDir}/prompt.zsh".source = ./assets/zsh/prompt.zsh;
      home.file."${config.programs.zsh.dotDir}/functions/j".source = ./assets/zsh/j;
      programs.zsh = {
        enable = true;
        dotDir = ".config/zsh";
        autocd = true;
        defaultKeymap = "emacs";
        enableAutosuggestions = true;
        history = {
          size = 100000;
          expireDuplicatesFirst = true;
          ignoreDups = true;
        };
        localVariables = {
          EMOJI_CLI_KEYBIND = "^n";
          EMOJI_CLI_USE_EMOJI = "yes";
          ZSH_HIGHLIGHT_HIGHLIGHTERS = [ "main" "brackets" "pattern" ];
        };
        shellAliases = import ./aliases.shell.nix;
        plugins = [
          {
            name = "emoji-cli";
            src = pkgs.fetchFromGitHub {
              owner = "b4b4r07";
              repo = "emoji-cli";
              rev = "26e2d67d566bfcc741891c8e063a00e0674abc92";
              sha256 = "0n88w4k5vaz1iyikpmlzdrrkxmfn91x5s4q405k1fxargr1w6bmx";
            };
          }
          {
            name = "zsh-z";
            src = pkgs.fetchFromGitHub {
              owner = "agkozak";
              repo = "zsh-z";
              rev = "5b903f8f5489783ee2a4af668a941b7d9a02efc9";
              sha256 = "07h6ksiqgqyf5m84hv5xf4jcqrl8q1cj8wd4z52cjmy82kk10fkn";
            };
          }
          {
            name = "async";
            src = pkgs.fetchFromGitHub {
              owner = "mafredri";
              repo = "zsh-async";
              rev = "v1.7.0";
              sha256 = "1jbbypgn0r4pilhv2s2p11vbkkvlnf75wrhxfcvr7bfjpzyp9wbc";
            };
          }
          {
            name = "zsh-completions";
            src = pkgs.fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-completions";
              rev = "922eee0706acb111e9678ac62ee77801941d6df2";
              sha256 = "04skzxv8j06f1snsx62qnca5f2183w0wfs5kz78rs8hkcyd6g89w";
            };
          }
          {
            name = "powerlevel10k";
            src = pkgs.fetchFromGitHub {
              owner = "romkatv";
              repo = "powerlevel10k";
              rev = "700910cd0421a7d25d2800cefa76eb6d80dc62a8";
              sha256 = "011ja4r3a8vbcs42js9nri4p8pi8z4ccqxl2qyf52pn3pfnidigj";
            };
          }
          {
            name = "zsh-nix-shell";
            src = pkgs.fetchFromGitHub {
              owner = "chisui";
              repo = "zsh-nix-shell";
              rev = "v0.1.0";
              sha256 = "0snhch9hfy83d4amkyxx33izvkhbwmindy0zjjk28hih1a9l2jmx";
            };
          }
        ];
        envExtra = ''
          export GOPATH=${config.home.homeDirectory}
          export WEBKIT_DISABLE_COMPOSITING_MODE=1;
          export PATH=$HOME/bin:$PATH
          if [ -d $HOME/.krew/bin ]; then
            export PATH=$HOME/.krew/bin:$PATH
          fi
        '';
        loginExtra = ''
          export GOPATH=${config.home.homeDirectory}
        '';
        initExtra = ''
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
          setopt hist_ignore_space
          alias -g L="|less"
          alias -g EEL=' 2>&1 | less'
          alias -g GB='`git rev-parse --abbrev-ref HEAD`'
          alias -g GR='`git rev-parse --show-toplevel`'
          (( $+commands[jq] )) && alias -g MJ="| jq -C '.'"  || alias -g MJ="| ${pkgs.python3}/bin/python -mjson.tool"
        '';
        profileExtra = ''
          if [ -e /home/vincent/.nix-profile/etc/profile.d/nix.sh ]; then . /home/vincent/.nix-profile/etc/profile.d/nix.sh; fi
          export NIX_PATH=$HOME/.nix-defexpr/channels:$NIX_PATH
        '';
      };
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
        defaultOptions = [ "--bind=ctrl-j:accept" ];
      };
    }
    (
      mkIf config.profiles.emacs.enable {
        /*programs.zsh.initExtra = ''
          export EDITOR=et
        '';*/
      }
    )
    (
      mkIf config.machine.home-manager {
        home.packages = with pkgs; [ hello ];
      }
    )
  ]);
}
