{
  lib,
  python3,
  static-nix-shell,
  stdenvNoCC,
  symlinkJoin,
  transmission_4,
}:

let
  sane-lib = {
    # TODO: we could simplify the lib/ folder structure
    # by auto-generating the setup.py files in `postPatch`, below
    bt = stdenvNoCC.mkDerivation {
      pname = "sane-lib-bt";
      version = "0.1.0";
      src = ./src/lib/bt;

      nativeBuildInputs = [
        python3.pkgs.pypaBuildHook
        python3.pkgs.pypaInstallHook
        python3.pkgs.setuptoolsBuildHook
      ];
      propagatedBuildInputs = [ transmission_4 ];
      nativeCheckInputs = [
        python3.pkgs.pythonImportsCheckHook
      ];

      pythonImportChecks = [
        "sane_bt"
      ];
      doCheck = true;
      strictDeps = true;
    };
    ssdp = stdenvNoCC.mkDerivation {
      pname = "sane-lib-ssdp";
      version = "0.1.0";
      src = ./src/lib/ssdp;

      nativeBuildInputs = [
        python3.pkgs.pypaBuildHook
        python3.pkgs.pypaInstallHook
        python3.pkgs.setuptoolsBuildHook
      ];
      nativeCheckInputs = [
        python3.pkgs.pythonImportsCheckHook
      ];

      pythonImportChecks = [
        "sane_ssdp"
      ];
      doCheck = true;
      strictDeps = true;
    };
  };

  sane-bin = {
    # anything added to this attrset gets symlink-joined into `sane-scripts`
    # and is made available through `sane-scripts.passthru`
    bt-add = static-nix-shell.mkPython3 {
      pname = "sane-bt-add";
      srcRoot = ./src;
      pkgs = [ "python3.pkgs.requests" "sane-scripts.lib.bt" ];
    };
    bt-rm = static-nix-shell.mkPython3 {
      pname = "sane-bt-rm";
      srcRoot = ./src;
      pkgs = [ "sane-scripts.lib.bt" ];
    };
    bt-search = static-nix-shell.mkPython3 {
      pname = "sane-bt-search";
      srcRoot = ./src;
      pkgs = [ "python3.pkgs.natsort" "python3.pkgs.requests" ];
    };
    bt-show = static-nix-shell.mkPython3 {
      pname = "sane-bt-show";
      srcRoot = ./src;
      pkgs = [ "sane-scripts.lib.bt" ];
    };
    clone = static-nix-shell.mkBash {
      pname = "sane-clone";
      srcRoot = ./src;
      pkgs = [ "nix" ];
    };
    date-set = static-nix-shell.mkBash {
      pname = "sane-date-set";
      srcRoot = ./src;
      pkgs = [ "systemd" ];
    };
    deadlines = static-nix-shell.mkYsh {
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
    ip-check = static-nix-shell.mkPython3 {
      pname = "sane-ip-check";
      srcRoot = ./src;
      pkgs = [ "miniupnpc" "python3.pkgs.requests" "sane-scripts.lib.ssdp" ];
    };
    ip-port-forward = static-nix-shell.mkPython3 {
      pname = "sane-ip-port-forward";
      srcRoot = ./src;
      pkgs = [ "inetutils" "miniupnpc" "sane-scripts.lib.ssdp"];
    };
    private-do = static-nix-shell.mkBash {
      pname = "sane-private-do";
      srcRoot = ./src;
      pkgs = [ "util-linux" ];
    };
    private-unlock = static-nix-shell.mkBash {
      pname = "sane-private-unlock";
      srcRoot = ./src;
      pkgs = [ "coreutils" "systemdMinimal" ];
    };
    private-unlock-remote = static-nix-shell.mkBash {
      pname = "sane-private-unlock-remote";
      srcRoot = ./src;
      pkgs = [ "openssh" "sane-scripts.secrets-dump" ];
    };
    profile = static-nix-shell.mkYsh {
      pname = "sane-profile";
      srcRoot = ./src;
      pkgs = [ "flamegraph" "perf" ];
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
    reclaim-boot-space = static-nix-shell.mkPython3 {
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
    stop-all-servo = static-nix-shell.mkYsh {
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
    sync-music = static-nix-shell.mkPython3 {
      pname = "sane-sync-music";
      srcRoot = ./src;
      pkgs = [ "ffmpeg" "python3.pkgs.unidecode" "sox" ];
    };
    tag-media = static-nix-shell.mkPython3 {
      pname = "sane-tag-media";
      srcRoot = ./src;
      pkgs = [ "python3.pkgs.mutagen" "python3.pkgs.pyexiftool" "python3.pkgs.pykakasi" "python3.pkgs.unidecode" ];
    };
    vpn = static-nix-shell.mkPython3 {
      pname = "sane-vpn";
      srcRoot = ./src;
      pkgs = [
        "bunpen"
        "iproute2"
        "networkmanager-split.nmcli"
        "sane-scripts.ip-check"
        "systemd"
      ];
    };
    which = static-nix-shell.mkBash {
      pname = "sane-which";
      srcRoot = ./src;
      pkgs = [ "coreutils-full" "file" "gnugrep" ];
    };
    wipe = static-nix-shell.mkBash {
      pname = "sane-wipe";
      srcRoot = ./src;
      pkgs = [ "dconf" "libsecret" "procps" "systemdMinimal" ];
    };
  };
in lib.recurseIntoAttrs (sane-bin // {
  lib = sane-lib;
  all = symlinkJoin {
    name = "sane-scripts";
    paths = lib.attrValues sane-bin;
  };
})
