{ config, lib, pkgs, ... }:

let
  inherit (builtins) readFile replaceStrings;
  inherit (lib) concatLines concatStringsSep genAttrs mapAttrsToList toShellVar;
  inherit ((import ../../nur.nix { inherit pkgs; }).lib) sgr;

  palette = import ../resources/palette.nix { inherit lib pkgs; };

  toAbbrs = kv: concatLines (mapAttrsToList (k: v: "abbr ${toShellVar k v}") kv);
in
{
  programs.bash = {
    enable = true;
    historyControl = [ "ignorespace" ];
    historyFile = "${config.home.homeDirectory}/akorg/resource/bash-history";
    historyFileSize = 1000000000;
    historySize = 100000000;
    initExtra = with palette.ansiFormat; ''
      HISTTIMEFORMAT='%FT%T%z ' # RFC 3339
      PS1='\[${magenta "\\]$\\["}\] '
    '';
  };

  programs.bat.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.warn_timeout = "5m";
    stdlib = with pkgs; ''
      # Adapted from https://github.com/direnv/direnv/wiki/Customizing-cache-location
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
        local hash name
        echo "''${direnv_layout_dirs[$PWD]:=$(
          case "$PWD" in
            "$HOME/project/"*|"$HOME/akorg/project/"*) store='user-state-cache';;
            *) store='user-runtime';;
          esac
          hash="$(sha256sum <<< "$PWD" | head --bytes 16)"
          name="''${PWD//\//-}"; name="''${name:1}"
          systemd-path --suffix "direnv/layouts/$name#$hash" "$store"
        )}"
      }

      use_gopass() {
        eval "$(${gopass-await}/bin/gopass-await "$@")"
      }
    '';
  };

  programs.eza.enable = true;

  programs.fzf = rec {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [ "--height 33%" "--no-separator" "--reverse" ];
    defaultCommand = "fd --no-ignore-parent --one-file-system --type file";
    fileWidgetCommand = defaultCommand;
    changeDirWidgetCommand = "fd --no-ignore-parent --one-file-system --type directory";
  };

  programs.zsh = {
    enable = true;
    autocd = false;

    history = {
      path = "${config.home.homeDirectory}/akorg/resource/zsh-history";
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = false;
      ignoreSpace = true;
      save = 100000000;
      size = 1000000000;
    };

    localVariables = {
      HIST_STAMPS = "yyyy-mm-dd";
      REPORTTIME = 10;
      WORDCHARS = "_.~;!#$%^";
    };

    initExtraBeforeCompInit = with pkgs; ''
      # Powerlevel10k instant prompt
      if [[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "$XDG_CACHE_HOME/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Completions
      fpath+=(${zsh-completions}/src)
    '';

    initExtra = replaceStrings [
      "@pdfimages@"
      "@zsh-abbr@"
      "@zsh-click@"
      "@zsh-powerlevel10k@"
      "@zsh-prezto-terminal@"
      "@zsh-syntax-highlighting@"
    ] (with pkgs; [
      "${poppler_utils}/bin/pdfimages"
      "${zsh-abbr}/share/zsh/plugins/zsh-abbr/zsh-abbr.plugin.zsh"
      "${zsh-click}/share/zsh/plugins/click/click.plugin.zsh"
      "${zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
      "${zsh-prezto}/share/zsh-prezto/modules/terminal/init.zsh"
      "${zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    ]) (readFile ../resources/init-extra.zsh);

    shellAliases =
      (genAttrs [
        "git"
        "yt-dlp"
      ] (c: "noglob ${c}")) // {
        all-history = "fc -l -Di 0";
        as = "gopass-env";
        cat = "bat --plain";
        cp = "cp --reflink=auto";
        get-clipboard = "wl-paste --no-newline --type 'text'";
        get-public-ip = "${pkgs.dig}/bin/dig +short @208.67.222.222 myip.opendns.com";
        e = "eza --all --group-directories-first --long --header --time-style long-iso";
        ffmpeg = "ffmpeg -hide_banner";
        ffprobe = "ffprobe -hide_banner";
        http = "noglob xh";
        https = "noglob xhs";
        j = "just-local";
        lsblk = "lsblk --output 'name,type,uuid,label,size,fstype,mountpoints' --paths";
        mv = "mv --no-clobber --verbose";
        p = "gopass";
        path = "nix-build --pure '<nixpkgs>' --attr";
        pt = "gopass-ydotool";
        rm = "rm --one-file-system --verbose";
        rsync = "rsync --compress --compress-choice=zstd --human-readable";
        set-clipboard = "wl-copy --type 'TEXT'";
        watch = "watch --color";
        wd = "git diff --no-index --word-diff --word-diff-regex '.'";
        xev = "echo 'Use ${sgr "22" "1" "wev"} instead.' >&2; return 1";
      };
  };

  home.file.".p10k.zsh".source = ../resources/p10k.zsh;

  xdg.configFile."zsh/abbreviations".text = toAbbrs {
    a = "git add --patch";
    aw = "add-words";
    b = "git switch --create";
    c = "git commit";
    ca = "git commit --amend";
    cb = "git-remote codeberg.org";
    cf = "git commit --amend --no-edit";
    cm = "git commit --message";
    d = "git diff ':!*.lock'";
    dl = "http --download get";
    ds = "git diff --staged ':!*.lock'";
    dsw = "git diff --staged --ignore-all-space ':!*.lock'";
    dua = "dua --stay-on-filesystem interactive";
    dw = "git diff --ignore-all-space ':!*.lock'";
    eh = "email-hash";
    et = "e --tree";
    f = "git commit --fixup";
    gf = "git fetch --all --jobs 4 --prune";
    gff = "git fetch --all --jobs 4 --prune && git merge --ff-only";
    gh = "git-remote github.com";
    gist = "git-remote gist.github.com";
    gl = "git-remote gitlab.com";
    h = "tig --all";
    hs = "home-manager switch";
    np = "nix-shell --packages";
    rebase = "git rebase --autostash --autosquash --interactive";
    s = "git status";
    stash = "git stash save --include-untracked";
    undo = "git restore --patch";
  };

  home.sessionVariables.EZA_COLORS = concatStringsSep ":" (mapAttrsToList (k: v: "${k}=${v.on}") (with palette.ansi; {
    ur = dim.white; # permission user-read
    uw = dim.white; # permission user-write
    ux = bold.green; # permission user-execute when file
    ue = bold.green; # permission user-execute when other
    gr = dim.white; # permission group-read
    gw = dim.white; # permission group-write
    gx = dim.white; # permission group-execute
    tr = bold.magenta; # permission others-read
    tw = bold.red; # permission others-write
    tx = dim.white; # permission others-execute
    su = bold.yellow; # permissions setuid/setgid/sticky when file
    sf = bold.yellow; # permissions setuid/setgid/sticky when other
    xa = bold.yellow; # extended attribute
    sn = dim.white; # size numeral
    ub = bold.white; # size unit when unprefixed
    uk = bold.blue; # size unit when K
    um = bold.yellow; # size unit when M
    ug = bold.red; # size unit when G
    ut = bold.red; # size unit when ≥T
    uu = black; # user when self
    un = red; # user when other
    gu = black; # group when member
    gn = red; # group when other
    da = dim.italic.white; # date
    lp = dim.white; # symlink path
    cc = bold.yellow; # escaped character
  }));

  home.sessionVariables.LS_COLORS = concatStringsSep ":" (mapAttrsToList (k: v: "${k}=${v.on}") (with palette.ansi; {
    di = bold.cyan; # directories
    ex = green; # executable files
    fi = white; # regular files
    pi = italic.blue; # named pipes
    so = italic.blue; # sockets
    bd = bold.blue; # block devices
    cd = bold.blue; # character devices
    ln = magenta; # symlinks
    or = red; # symlinks with no target
  }));
}
