{
  bunpen,
  coreutils,
  coreutils-full,
  dconf,
  ffmpeg,
  file,
  findutils,
  flamegraph,
  gnugrep,
  gnused,
  ifuse,
  inetutils,
  inotify-tools,
  iproute2,
  lib,
  libsecret,
  miniupnpc,
  ncurses,
  nettools,
  networkmanager-split,
  nix,
  oath-toolkit,
  openssh,
  perf,
  procps,
  python3,
  rsync,
  sane-scripts,
  sops,
  sox,
  ssh-to-age,
  static-nix-shell,
  stdenvNoCC,
  symlinkJoin,
  systemd,
  systemdMinimal,
  transmission_4,
  util-linux,
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
      packages = {
        "python3.pkgs.requests" = python3.pkgs.requests;
        "sane-scripts.lib.bt" = sane-scripts.lib.bt;
      };
    };
    bt-rm = static-nix-shell.mkPython3 {
      pname = "sane-bt-rm";
      srcRoot = ./src;
      packages = {
        "sane-scripts.lib.bt" = sane-scripts.lib.bt;
      };
    };
    bt-search = static-nix-shell.mkPython3 {
      pname = "sane-bt-search";
      srcRoot = ./src;
      packages = {
        "python3.pkgs.requests" = python3.pkgs.requests;
      };
    };
    bt-show = static-nix-shell.mkPython3 {
      pname = "sane-bt-show";
      srcRoot = ./src;
      packages = {
        "sane-scripts.lib.bt" = sane-scripts.lib.bt;
      };
    };
    clone = static-nix-shell.mkBash {
      pname = "sane-clone";
      srcRoot = ./src;
      packages = { inherit nix; };
    };
    date-set = static-nix-shell.mkBash {
      pname = "sane-date-set";
      srcRoot = ./src;
      packages = { inherit systemd; };
    };
    deadlines = static-nix-shell.mkYsh {
      pname = "sane-deadlines";
      srcRoot = ./src;
      packages = {
        inherit
          coreutils-full
          gnused
          ;
      };
    };
    dev-cargo-loop = static-nix-shell.mkBash {
      pname = "sane-dev-cargo-loop";
      srcRoot = ./src;
      packages = {
        inherit
          inotify-tools
          ncurses
          ;
      };
    };
    find-dotfiles = static-nix-shell.mkBash {
      pname = "sane-find-dotfiles";
      srcRoot = ./src;
      packages = {
        inherit findutils;
      };
    };
    ip-check = static-nix-shell.mkPython3 {
      pname = "sane-ip-check";
      srcRoot = ./src;
      packages = {
        inherit miniupnpc;
        "python3.pkgs.requests" = python3.pkgs.requests;
        "sane-scripts.lib.ssdp" = sane-scripts.lib.ssdp;
      };
    };
    ip-port-forward = static-nix-shell.mkPython3 {
      pname = "sane-ip-port-forward";
      srcRoot = ./src;
      packages = {
        inherit
          inetutils
          miniupnpc
          ;
        "sane-scripts.lib.ssdp" = sane-scripts.lib.ssdp;
      };
    };
    private-do = static-nix-shell.mkBash {
      pname = "sane-private-do";
      srcRoot = ./src;
      packages = {
        inherit util-linux;
      };
    };
    private-unlock = static-nix-shell.mkBash {
      pname = "sane-private-unlock";
      srcRoot = ./src;
      packages = {
        inherit
          coreutils
          systemdMinimal
          ;
        };
    };
    private-unlock-remote = static-nix-shell.mkBash {
      pname = "sane-private-unlock-remote";
      srcRoot = ./src;
      packages = {
        inherit openssh;
        "sane-scripts.secrets-dump" = sane-scripts.secrets-dump;
      };
    };
    profile = static-nix-shell.mkYsh {
      pname = "sane-profile";
      srcRoot = ./src;
      packages = {
        inherit
          flamegraph
          perf
          ;
      };
    };
    rcp = static-nix-shell.mkBash {
      pname = "sane-rcp";
      srcRoot = ./src;
      packages = {
        inherit rsync;
      };
    };
    reboot = static-nix-shell.mkBash {
      pname = "sane-reboot";
      srcRoot = ./src;
      packages = {
        inherit
          nettools
          systemd
          ;
      };
    };
    reclaim-boot-space = static-nix-shell.mkPython3 {
      pname = "sane-reclaim-boot-space";
      srcRoot = ./src;
    };
    reclaim-disk-space = static-nix-shell.mkBash {
      pname = "sane-reclaim-disk-space";
      srcRoot = ./src;
      packages = { inherit nix; };
    };
    secrets-dump = static-nix-shell.mkBash {
      pname = "sane-secrets-dump";
      srcRoot = ./src;
      packages = {
        inherit
          gnugrep
          sops
          oath-toolkit
          ;
      };
    };
    secrets-unlock = static-nix-shell.mkBash {
      pname = "sane-secrets-unlock";
      srcRoot = ./src;
      packages = {
        inherit
          coreutils-full
          openssh
          ssh-to-age
          ;
      };
    };
    secrets-update-keys = static-nix-shell.mkBash {
      pname = "sane-secrets-update-keys";
      srcRoot = ./src;
      packages = {
        inherit
          coreutils-full
          findutils
          sops
          ;
      };
    };
    shutdown = static-nix-shell.mkBash {
      pname = "sane-shutdown";
      srcRoot = ./src;
      packages = {
        inherit
          nettools
          systemd
          ;
      };
    };
    stop-all-servo = static-nix-shell.mkYsh {
      pname = "sane-stop-all-servo";
      srcRoot = ./src;
      packages = {
        inherit systemd;
      };
    };
    sudo-redirect = static-nix-shell.mkBash {
      pname = "sane-sudo-redirect";
      srcRoot = ./src;
      packages = {
        inherit coreutils-full;
      };
    };
    sync-from-iphone = static-nix-shell.mkZsh {
      pname = "sane-sync-from-iphone";
      srcRoot = ./src;
      packages = {
        inherit
          coreutils-full
          ifuse
          rsync
          ;
      };
    };
    sync-music = static-nix-shell.mkPython3 {
      pname = "sane-sync-music";
      srcRoot = ./src;
      packages = {
        inherit
          ffmpeg
          sox
          ;
        "python3.pkgs.unidecode" = python3.pkgs.unidecode;
      };
    };
    tag-media = static-nix-shell.mkPython3 {
      pname = "sane-tag-media";
      srcRoot = ./src;
      packages = {
        "python3.pkgs.mutagen" = python3.pkgs.mutagen;
        "python3.pkgs.pyexiftool" = python3.pkgs.pyexiftool;
        "python3.pkgs.pykakasi" = python3.pkgs.pykakasi;
        "python3.pkgs.unidecode" = python3.pkgs.unidecode;
      };
    };
    vpn = static-nix-shell.mkPython3 {
      pname = "sane-vpn";
      srcRoot = ./src;
      packages = {
        inherit
          bunpen
          iproute2
          systemd
          ;
        "networkmanager-split.nmcli" = networkmanager-split.nmcli;
        "sane-scripts.ip-check" = sane-scripts.ip-check;
      };
    };
    which = static-nix-shell.mkBash {
      pname = "sane-which";
      srcRoot = ./src;
      packages = {
        inherit
          coreutils-full
          file
          gnugrep
          ;
      };
    };
    wipe = static-nix-shell.mkBash {
      pname = "sane-wipe";
      srcRoot = ./src;
      packages = {
        inherit
          dconf
          libsecret
          procps
          systemdMinimal
          ;
      };
    };
  };
in lib.recurseIntoAttrs (sane-bin // {
  lib = sane-lib;
  all = symlinkJoin {
    name = "sane-scripts";
    paths = lib.attrValues sane-bin;
  };
})
