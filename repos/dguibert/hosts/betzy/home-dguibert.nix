{
  config,
  pkgs,
  lib,
  ...
} @ args:
with lib; {
  # Choose your themee
  themes.base16 = {
    enable = true;
    scheme = "solarized";
    variant = "solarized-dark";

    # Add extra variables for inclusion in custom templates
    extraParams = {
      fontname = mkDefault "Inconsolata LGC for Powerline";
      #headerfontname = mkDefault  "Cabin";
      bodysize = mkDefault "10";
      headersize = mkDefault "12";
      xdpi = mkDefault ''
        Xft.hintstyle: hintfull
      '';
    };
  };
  nixpkgs.overlays = [
    (import ./overlay.nix)
    (final: prev: {
      pinentry = prev.pinentry.override {enabledFlavors = ["curses" "tty"];};
    })
  ];
  services.gpg-agent.pinentryFlavor = lib.mkForce "curses";

  programs.home-manager.enable = true;

  programs.bash.enable = true;
  programs.bash.bashrcExtra =
    /*
    (homes.withoutX11 args).programs.bash.initExtra +
    */
    ''
      export PATH=$HOME/bin:$PATH
      #export LD_LIBRARY_PATH=${pkgs.sssd}/lib:$LD_LIBRARY_PATH

      case $HOSTNAME in
        spartan0)
        ;;
        spartan*)
        export TMP=/dev/shm; export TMPDIR=$TMP; export TEMP=$TMP; export TEMPDIR=$TMP
        ;;
      esac
    '';

  #programs.bash.historySize = 50000;
  #programs.bash.historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
  #programs.bash.historyIgnore = [ "ls" "cd" "clear" "[bf]g" ];

  programs.bash.historySize = -1; # no truncation
  programs.bash.historyFile = "$HOME/.bash_history";
  programs.bash.historyFileSize = -1; # no truncation
  programs.bash.historyControl = ["erasedups" "ignoredups" "ignorespace"];
  programs.bash.historyIgnore = [
    "ls"
    "cd"
    "clear"
    "[bf]g"
    " *"
    "cd -"
    "history"
    "history -*"
    "man"
    "man *"
    "pwd"
    "exit"
    "date"
    "* --help:"
  ];

  programs.bash.shellAliases.ls = "ls --color";

  programs.bash.initExtra = ''
    export HISTCONTROL
    export HISTFILE
    export HISTFILESIZE
    export HISTIGNORE
    export HISTSIZE
    unset HISTTIMEFORMAT
    export PROMPT_COMMAND="history -n; history -w; history -c; history -r"
    # https://www.gnu.org/software/emacs/manual/html_node/tramp/Remote-shell-setup.html#index-TERM_002c-environment-variable-1
    test "$TERM" != "dumb" || return

    # Provide a nice prompt.
    PS1=""
    PS1+='\[\033[01;37m\]$(exit=$?; if [[ $exit == 0 ]]; then echo "\[\033[01;32m\]✓"; else echo "\[\033[01;31m\]✗ $exit"; fi)'
    PS1+='$(ip netns identify 2>/dev/null)' # sudo setfacl -m u:$USER:rx /var/run/netns
    PS1+=' ''${GIT_DIR:+ \[\033[00;32m\][$(basename $GIT_DIR)]}'
    PS1+=' ''${ENVRC:+ \[\033[00;33m\]env:$ENVRC}'
    PS1+=' ''${SLURM_NODELIST:+ \[\033[01;34m\][$SLURM_NODELIST]\[\033[00m\]}'
    PS1+=' \[\033[00;32m\]\u@\h\[\033[01;34m\] \W '
    if !  command -v __git_ps1 >/dev/null; then
      if [ -e $HOME/code/git-prompt.sh ]; then
        source $HOME/code/git-prompt.sh
      fi
    fi
    if command -v __git_ps1 >/dev/null; then
      PS1+='$(__git_ps1 "|%s|")'
    fi
    PS1+='$\[\033[00m\] '

    export PS1
    case $TERM in
      dvtm*|st*|rxvt|*term)
        trap 'echo -ne "\e]0;$BASH_COMMAND\007"' DEBUG
      ;;
    esac

    eval "$(${pkgs.coreutils}/bin/dircolors)" &>/dev/null
    export BASE16_SHELL_SET_BACKGROUND=false
    source ${config.lib.base16.base16template "shell"}

    export TODOTXT_DEFAULT_ACTION=ls
    alias t='todo.sh'

    tput smkx
    case $HOSTNAME in
      spartan0)
      ;;
      spartan*)
      export TMP=/dev/shm; export TMPDIR=$TMP; export TEMP=$TMP; export TEMPDIR=$TMP
      ;;
    esac
  '';

  home.file.".vim/base16.vim".source = config.lib.base16.base16template "vim";
  #config.lib.base16.base16template "vim";

  programs.git.enable = true;
  programs.git.package = pkgs.gitFull;
  programs.git.userName = "David Guibert";
  programs.git.userEmail = "david.guibert@gmail.com";
  programs.git.aliases.files = "ls-files -v --deleted --modified --others --directory --no-empty-directory --exclude-standard";
  programs.git.aliases.wdiff = "diff --word-diff=color --unified=1";
  programs.git.aliases.bd = "!git for-each-ref --sort='-committerdate:iso8601' --format='%(committerdate:iso8601)%09%(refname)'";
  programs.git.aliases.bdr = "!git for-each-ref --sort='-committerdate:iso8601' --format='%(committerdate:iso8601)%09%(refname)' refs/remotes/$1";
  programs.git.aliases.bs = "branch -v -v";
  programs.git.aliases.df = "diff";
  programs.git.aliases.dn = "diff --name-only";
  programs.git.aliases.dp = "diff --no-ext-diff";
  programs.git.aliases.ds = "diff --stat -w";
  programs.git.aliases.dt = "difftool";
  #programs.git.ignores
  programs.git.iniContent.clean.requireForce = true;
  programs.git.iniContent.rerere.enabled = true;
  programs.git.iniContent.rerere.autoupdate = true;
  programs.git.iniContent.rebase.autosquash = true;
  programs.git.iniContent.credential.helper = "password-store";
  programs.git.iniContent."url \"software.ecmwf.int\"".insteadOf = "ssh://git@software.ecmwf.int:7999";
  programs.git.iniContent.color.branch = "auto";
  programs.git.iniContent.color.diff = "auto";
  programs.git.iniContent.color.interactive = "auto";
  programs.git.iniContent.color.status = "auto";
  programs.git.iniContent.color.ui = "auto";
  programs.git.iniContent.diff.tool = "vimdiff";
  programs.git.iniContent.diff.renames = "copies";
  programs.git.iniContent.merge.tool = "vimdiff";

  # http://ubuntuforums.org/showthread.php?t=1150822
  ## Save and reload the history after each command finishes
  home.sessionVariables.SQUEUE_FORMAT = "%.18i %.25P %35j %.8u %.2t %.10M %.6D %.6C %.6z %.15E %20R %W";
  #home.sessionVariables.SINFO_FORMAT="%30N  %.6D %.6c %15F %10t %20f %P"; # with state
  home.sessionVariables.SINFO_FORMAT = "%30N  %.6D %.6c %15F %20f %P";
  home.sessionVariables.PATH = "$HOME/bin:$PATH";
  #home.sessionVariables.MANPATH="$HOME/man:$MANPATH:/share/man";
  programs.man.enable = false; # RHEL 8 manpath fork bomb
  home.sessionVariables.PAGER = "less -R";
  home.sessionVariables.EDITOR = "vim";
  home.sessionVariables.GIT_PS1_SHOWDIRTYSTATE = 1;
  # ✗ 1    dguibert@vbox-57nvj72 ~ $ systemctl --user status
  # Failed to read server status: Process org.freedesktop.systemd1 exited with status 1
  # ✗ 130    dguibert@vbox-57nvj72 ~ $ export XDG_RUNTIME_DIR=/run/user/$(id -u)
  home.sessionVariables.XDG_RUNTIME_DIR = "/run/user/$(id -u)";

  # Fix stupid java applications like android studio
  home.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";

  home.packages = with pkgs; [
    (vim_configurable.override {
      guiSupport = "no";
      libX11 = null;
      libXext = null;
      libSM = null;
      libXpm = null;
      libXt = null;
      libXaw = null;
      libXau = null;
      libXmu = null;
      libICE = null;
    })

    rsync

    gitAndTools.gitRemoteGcrypt
    gitAndTools.git-crypt

    gnumake
    #nix-repl
    pstree

    #teamviewer
    tig
    #haskellPackages.nix-deploy
    htop
    tree

    #wpsoffice
    file
    bc
    unzip

    sshfs-fuse

    moreutils

    editorconfig-core-c
    todo-txt-cli
    ctags
    dvtm
    abduco
    gnupg1compat

    nix
    gitAndTools.git-annex
    gitAndTools.hub
    gitAndTools.git-crypt
    gitFull #guiSupport is harmless since we also installl xpra
    (pkgs.writeScriptBin "git-annex-diff-wrapper" ''
      #!${runtimeShell}
      LANG=C ${diffutils}/bin/diff -u "$1" "$2"
      exit 0
    '')
    python3Packages.datalad # error: boto-2.49.0 not supported for interpreter python3.9
    subversion
    tig
    jq
    lsof
    #xpra
    htop
    tree

    nxsession
    xorg.setxkbmap

    # testing (removed 20171122)
    #Mitos
    #MemAxes
    python3

    socat
    pv
    netcat
  ];

  programs.direnv.enable = true;

  services.gpg-agent.enable = true;
  services.gpg-agent.enableSshSupport = true;
  # https://blog.eleven-labs.com/en/openpgp-almost-perfect-key-pair-part-1/

  home.stateVersion = "20.09";
}
