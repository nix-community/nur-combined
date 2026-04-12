{
  pkgs,
  lib,
  ...
}:

let
  self = import ../. { inherit pkgs; };
in
{
  users.users.user = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "wheel"
      "dialout"
    ];
  };
  services.getty.autologinUser = lib.mkForce "user";

  # Systemd tools pager should not take over when the output fits on
  # one screen. See man:less(1)
  environment.sessionVariables.SYSTEMD_LESS = "FRX";

  users.users."user".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEVwcaKID2HpE4ZRYClT1URJCRXiSPsJR4FC5TwnlmCS"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILP3LpZ81RkReP5MG3A+MoRB93E+XENLCFh9qmQNcuXV daniel.nagy@wiit.cloud"
  ];
  users.users."root".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEVwcaKID2HpE4ZRYClT1URJCRXiSPsJR4FC5TwnlmCS"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILP3LpZ81RkReP5MG3A+MoRB93E+XENLCFh9qmQNcuXV daniel.nagy@wiit.cloud"
  ];

  environment.systemPackages = with pkgs; [
    jq
    yq-go
    socat
    unzip
    pv
    ## Processes
    killall
    bubblewrap
    # Files
    tree
    file
    fd
    ripgrep
    lsof
    # Networking tools
    mtr
    dnsutils
    (rclone.overrideAttrs {
      patches = pkgs.fetchpatch {
        url = "https://github.com/rclone/rclone/compare/master...nagy:rclone:mount-readonly.patch";
        hash = "sha256-KNAIwelGO3tmwKoAhk56gaMj8KDcdG3xpTQwBxhGyTk=";
      };
    })
    dool
    doggo
    optipng
    taplo
    libjxl
    jqfmt
    jless
    self.all-converters
    glab
    jc

    # for man pages
    (lib.getMan pkgs.msmtp)
    (lib.getMan pkgs.isync)
    pkgs.darkhttpd
  ];

  # tmpfs on all machines
  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "100%";
  };

  # Almost all hosts should have this timezone
  time.timeZone = lib.mkDefault "Europe/Berlin";

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  programs.ssh = {
    enableAskPassword = lib.mkForce false;
    extraConfig = ''
      Host *
        StrictHostKeyChecking accept-new
        ControlPath /tmp/ssh-%r@%h:%p
        ServerAliveInterval 60
        ServerAliveCountMax 2
        SendEnv COLORTERM
    '';
  };

  services.openssh = {
    enable = lib.mkDefault true;
    settings.PrintLastLog = false;
    settings.AcceptEnv = [
      "COLORTERM"
    ];
  };

  programs.fuse.userAllowOther = true;

  environment.shellAliases = {
    mv = "mv --no-clobber";
    smv = "mv --no-clobber";
    # If the last character of the alias value is a blank, then the next command
    # word following the alias is also checked for alias expansion.
    # https://www.gnu.org/software/bash/manual/bash.html#Aliases
    # https://news.ycombinator.com/item?id=25243730
    sudo = "sudo ";
    to32 = "nix-hash --to-base32 --type sha256";
    lt = "ls --human-readable --size -1 -S --classify";
    ll = "ls --human-readable -l";
    la = "ls --human-readable -l --all";
    llH = "ls --human-readable -l --dereference-command-line";
    laH = "ls --human-readable --all -l --dereference-command-line";
    ltH = "ls --human-readable --size -1 -S --classify --dereference-command-line";
    path = "echo -e \${PATH//:/\\\\n}";
    nixpath = "echo -e \${NIX_PATH//:/\\\\n} | column -s= -t";
    manpath = "echo -e \${MANPATH//:/\\\\n}";
    fastping = "ping -c 20 -i.2";
    reset = "tput reset";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
    "......" = "cd ../../../../..";
    "......." = "cd ../../../../../..";
  };

  programs.bash.interactiveShellInit = ''
    function .r() {
      cd -- /run/user/1000/
      source "$@"
      cd -
    }
    shopt -s autocd
  '';

  # environment.localBinInPath = true;
  environment.homeBinInPath = true;

  environment.sessionVariables = {
    # Shell History
    HISTCONTROL = "ignoredups:ignorespace";
    HISTFILESIZE = "10000000";
    HISTSIZE = "1000000";
    HISTFILE = "$HOME/.local/share/bash_history";

    # Misc
    LESSHISTFILE = "-";
    WATCH_INTERVAL = "1";
    # zstd auto detect parallel
    ZSTD_NBTHREADS = "0";
    # https://github.com/denoland/deno/blob/21065797f6dce285e55705007f54abe2bafb611c/cli/tools/upgrade.rs#L184-L187
    DENO_NO_UPDATE_CHECK = "1";

    IPFS_GATEWAY = lib.mkDefault "https://ipfs.io";

    # Release memory of polars data library, because they hardcode "-1" ms muzzy decay
    # https://github.com/pola-rs/polars/issues/23128#issuecomment-2976179171
    _RJEM_MALLOC_CONF = "background_thread:true,dirty_decay_ms:500,muzzy_decay_ms:500";

    # GitLab CLI
    GLAB_CHECK_UPDATE = "false";
    GLAB_SEND_TELEMETRY = "false";
  };

  networking.nameservers = lib.mkDefault [ "1.1.1.1" ];

  # too noisy, not needed by default
  networking.firewall.logRefusedConnections = lib.mkDefault false;
  networking.firewall.rejectPackets = lib.mkDefault true;

  boot.kernel.sysctl = {
    # disable coredumps
    # https://wiki.archlinux.org/index.php/Core_dump#Disabling_automatic_core_dumps
    "kernel.core_pattern" = "|/bin/false";
  };

  # not used anywhere, might save some space.
  boot.supportedFilesystems.zfs = lib.mkForce false;
}
