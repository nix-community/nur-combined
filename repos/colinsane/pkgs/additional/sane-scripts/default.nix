{ lib
, python3Packages
, static-nix-shell
, symlinkJoin
, transmission
}:

let
  sane-lib = {
    # TODO: we could simplify the lib/ folder structure
    # by auto-generating the setup.py files in `postPatch`, below
    bt = python3Packages.buildPythonPackage {
      pname = "sane-lib-bt";
      version = "0.1.0";
      format = "setuptools";
      src = ./src/lib/bt;
      propagatedBuildInputs = [ transmission ];
      pythonImportChecks = [
        "sane_bt"
      ];
    };
    ssdp = python3Packages.buildPythonPackage {
      pname = "sane-lib-ssdp";
      version = "0.1.0";
      format = "setuptools";
      src = ./src/lib/ssdp;
      pythonImportChecks = [
        "sane_ssdp"
      ];
    };
  };

  sane-bin = {
    # anything added to this attrset gets symlink-joined into `sane-scripts`
    # and is made available through `sane-scripts.passthru`
    backup-ls = static-nix-shell.mkBash {
      pname = "sane-backup-ls";
      srcRoot = ./src;
      pkgs = [ "duplicity" ];
    };
    backup-restore = static-nix-shell.mkBash {
      pname = "sane-backup-restore";
      srcRoot = ./src;
      pkgs = [ "duplicity" ];
    };
    bt-add = static-nix-shell.mkPython3Bin {
      pname = "sane-bt-add";
      srcRoot = ./src;
      pyPkgs = [ "requests" "sane-lib.bt" ];
      pkgs = [ "sane-scripts.lib.bt.propagatedBuildInputs" ];
    };
    bt-rm = static-nix-shell.mkPython3Bin {
      pname = "sane-bt-rm";
      srcRoot = ./src;
      pyPkgs = [ "sane-lib.bt" ];
      pkgs = [ "sane-scripts.lib.bt.propagatedBuildInputs" ];
    };
    bt-search = static-nix-shell.mkPython3Bin {
      pname = "sane-bt-search";
      srcRoot = ./src;
      pyPkgs = [ "natsort" "requests" ];
    };
    bt-show = static-nix-shell.mkPython3Bin {
      pname = "sane-bt-show";
      srcRoot = ./src;
      pyPkgs = [ "sane-lib.bt" ];
      pkgs = [ "sane-scripts.lib.bt.propagatedBuildInputs" ];
    };
    clone = static-nix-shell.mkBash {
      pname = "sane-clone";
      srcRoot = ./src;
      pkgs = [ "nix" ];
    };
    deadlines = static-nix-shell.mkBash {
      pname = "sane-deadlines";
      srcRoot = ./src;
      pkgs = [ "coreutils-full" "gnused" ];
    };
    dev-cargo-loop = static-nix-shell.mkBash {
      pname = "sane-dev-cargo-loop";
      srcRoot = ./src;
      pkgs = [ "inotify-tools" "ncurses" ];
    };
    find-dotfiles = static-nix-shell.mkBash {
      pname = "sane-find-dotfiles";
      srcRoot = ./src;
      pkgs = [ "findutils" ];
    };
    ip-check = static-nix-shell.mkPython3Bin {
      pname = "sane-ip-check";
      srcRoot = ./src;
      pkgs = [ "miniupnpc" ];
      pyPkgs = [ "requests" "sane-lib.ssdp" ];
    };
    ip-port-forward = static-nix-shell.mkPython3Bin {
      pname = "sane-ip-port-forward";
      srcRoot = ./src;
      pkgs = [ "inetutils" "miniupnpc" ];
      pyPkgs = [ "sane-lib.ssdp" ];
    };
    private-change-passwd = static-nix-shell.mkBash {
      pname = "sane-private-change-passwd";
      srcRoot = ./src;
      pkgs = [ "gocryptfs" "rsync" ];
    };
    private-do = static-nix-shell.mkBash {
      pname = "sane-private-do";
      srcRoot = ./src;
      pkgs = [ "util-linux" ];
    };
    private-init = static-nix-shell.mkBash {
      pname = "sane-private-init";
      srcRoot = ./src;
      pkgs = [ "gocryptfs" ];
    };
    private-lock = static-nix-shell.mkBash {
      pname = "sane-private-lock";
      srcRoot = ./src;
      pkgs = [ "util-linux.mount" ];
    };
    private-unlock = static-nix-shell.mkBash {
      pname = "sane-private-unlock";
      srcRoot = ./src;
      pkgs = [ "util-linux.mount" ];
    };
    rcp = static-nix-shell.mkBash {
      pname = "sane-rcp";
      srcRoot = ./src;
      pkgs = [ "rsync" ];
    };
    reboot = static-nix-shell.mkBash {
      pname = "sane-reboot";
      srcRoot = ./src;
      pkgs = [ "nettools" "systemd" ];
    };
    reclaim-boot-space = static-nix-shell.mkPython3Bin {
      pname = "sane-reclaim-boot-space";
      srcRoot = ./src;
    };
    reclaim-disk-space = static-nix-shell.mkBash {
      pname = "sane-reclaim-disk-space";
      srcRoot = ./src;
      pkgs = [ "nix" ];
    };
    secrets-dump = static-nix-shell.mkBash {
      pname = "sane-secrets-dump";
      srcRoot = ./src;
      pkgs = [ "gnugrep" "sops" "oath-toolkit" ];
    };
    secrets-unlock = static-nix-shell.mkBash {
      pname = "sane-secrets-unlock";
      srcRoot = ./src;
      pkgs = [ "coreutils-full" "openssh" "ssh-to-age" ];
    };
    secrets-update-keys = static-nix-shell.mkBash {
      pname = "sane-secrets-update-keys";
      srcRoot = ./src;
      pkgs = [ "coreutils-full" "findutils" "sops" ];
    };
    shutdown = static-nix-shell.mkBash {
      pname = "sane-shutdown";
      srcRoot = ./src;
      pkgs = [ "nettools" "systemd" ];
    };
    stop-all-servo = static-nix-shell.mkBash {
      pname = "sane-stop-all-servo";
      srcRoot = ./src;
      pkgs = [ "systemd" ];
    };
    sudo-redirect = static-nix-shell.mkBash {
      pname = "sane-sudo-redirect";
      srcRoot = ./src;
      pkgs = [ "coreutils-full" ];
    };
    sync-from-iphone = static-nix-shell.mkZsh {
      pname = "sane-sync-from-iphone";
      srcRoot = ./src;
      pkgs = [ "coreutils-full" "ifuse" "rsync" ];
    };
    sync-music = static-nix-shell.mkPython3Bin {
      pname = "sane-sync-music";
      srcRoot = ./src;
      pkgs = [ "ffmpeg" "sox" ];
      pyPkgs = [ "unidecode" ];
    };
    tag-music = static-nix-shell.mkPython3Bin {
      pname = "sane-tag-music";
      srcRoot = ./src;
      pyPkgs = [ "mutagen" ];
    };
    vpn = static-nix-shell.mkBash {
      pname = "sane-vpn";
      srcRoot = ./src;
      pkgs = [ "coreutils-full" "sane-scripts.ip-check" ];
    };
    which = static-nix-shell.mkBash {
      pname = "sane-which";
      srcRoot = ./src;
      pkgs = [ "coreutils-full" "file" "gnugrep" ];
    };
    wipe = static-nix-shell.mkBash {
      pname = "sane-wipe";
      srcRoot = ./src;
      pkgs = [ "dconf" "libsecret" "s6-rc" ];
    };
  };
in sane-bin // {
  lib = sane-lib;
  all = symlinkJoin {
    name = "sane-scripts";
    paths = lib.attrValues sane-bin;
  };
}
