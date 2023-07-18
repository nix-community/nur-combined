{ config, lib, pkgs, ...}:

let
  # powerlevel10k prompt config
  # p10k.zsh is the auto-generated config, and i overwrite those defaults here, below.
  p10k-overrides = ''
    # powerlevel10k launches a gitstatusd daemon to accelerate git prompt queries.
    # this keeps open file handles for any git repo i touch for 60 minutes (by default).
    # that prevents unmounting whatever device the git repo is on -- particularly problematic for ~/private.
    # i can disable gitstatusd and get slower fallback git queries:
    # - either universally
    # - or selectively by path
    # see: <https://github.com/romkatv/powerlevel10k/issues/246>
    typeset -g POWERLEVEL9K_VCS_DISABLED_DIR_PATTERN='(/home/colin/private/*|/home/colin/knowledge/*)'
    # typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=true

    # show user@host also when logged into the current machine.
    # default behavior is to show it only over ssh.
    typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_CONTENT_EXPANSION='$P9K_CONTENT'
  '';

  prezto-init = ''
    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source ${pkgs.zsh-prezto}/share/zsh-prezto/init.zsh
  '';
in {
  config = lib.mkIf config.sane.zsh.p10k {
    sane.programs.zsh = {
      # prezto = oh-my-zsh fork; controls prompt, auto-completion, etc.
      # see: https://github.com/sorin-ionescu/prezto
      # this file is auto-sourced by the prezto init.zsh script.
      # TODO: i should work to move away from prezto:
      # - it's FUCKING SLOW to initialize (that might also be powerlevel10k tho)
      # - it messes with my other `setopt`s
      fs.".config/zsh/.zpreztorc".symlink.text = ''
        zstyle ':prezto:*:*' color 'yes'
        zstyle ':prezto:module:utility' correct 'no'  # prezto: don't setopt CORRECT

        # modules (they ship with prezto):
        # ENVIRONMENT: configures jobs to persist after shell exit; other basic niceties
        # TERMINAL: auto-titles terminal (e.g. based on cwd)
        # EDITOR: configures shortcuts like Ctrl+U=undo, Ctrl+L=clear
        # HISTORY: `history-stat` alias, setopts for good history defaults
        # DIRECTORY: sets AUTO_CD, adds `d` alias to list directory stack, and `1`-`9` to cd that far back the stack. also overrides CLOBBER and some other options
        # SPECTRUM: helpers for term colors and styling. used by prompts? might be unnecessary
        # UTILITY: configures aliases like `ll`, `la`, disables globbing for things like rsync
        #   adds aliases like `get` to fetch a file. also adds `http-serve` alias??
        # COMPLETION: tab completion. requires `utility` module prior to loading
        zstyle ':prezto:load' pmodule \
          'environment' \
          'terminal' \
          'editor' \
          'history' \
          'spectrum' \
          'utility' \
          'completion' \
          'prompt'

        # default keymap. try also `vicmd` (vim normal mode, AKA "cmd mode") or `vi`.
        zstyle ':prezto:module:editor' key-bindings 'emacs'

        zstyle ':prezto:module:prompt' theme 'powerlevel10k'

        # disable `mv` confirmation (and `rm`, too, unfortunately)
        zstyle ':prezto:module:utility' safe-ops 'no'
      '';
    };

    programs.zsh.interactiveShellInit = (builtins.readFile ./p10k.zsh)
      + p10k-overrides
      + prezto-init
    ;
  };
}
