{ config, lib, ... }:
let
  declPackageSet = pkgs: {
    packageUnwrapped = null;
    suggestedPrograms = pkgs;
  };
in
{
  sane.programs = {
    "sane-scripts.backup" = declPackageSet [
      "sane-scripts.backup-ls"
      "sane-scripts.backup-restore"
    ];
    "sane-scripts.bittorrent" = declPackageSet [
      "sane-scripts.bt-add"
      "sane-scripts.bt-rm"
      "sane-scripts.bt-search"
      "sane-scripts.bt-show"
    ];
    "sane-scripts.dev" = declPackageSet [
      "sane-scripts.clone"
      "sane-scripts.dev-cargo-loop"
    ];
    "sane-scripts.cli" = declPackageSet [
      "sane-scripts.deadlines"
      "sane-scripts.find-dotfiles"
      "sane-scripts.ip-check"
      "sane-scripts.private-do"
      "sane-scripts.private-init"
      "sane-scripts.private-lock"
      "sane-scripts.private-unlock"
      "sane-scripts.rcp"
      "sane-scripts.reboot"
      "sane-scripts.reclaim-boot-space"
      "sane-scripts.reclaim-disk-space"
      "sane-scripts.secrets-dump"
      "sane-scripts.secrets-update-keys"
      "sane-scripts.shutdown"
      "sane-scripts.sudo-redirect"
      "sane-scripts.tag-media"
      "sane-scripts.vpn"
      "sane-scripts.which"
      "sane-scripts.wipe"
    ];
    "sane-scripts.sys-utils" = declPackageSet [
      "sane-scripts.ip-port-forward"
      "sane-scripts.sync-music"
    ];

    "sane-scripts.backup-ls" = {};
    "sane-scripts.backup-restore" = {};

    "sane-scripts.bt-add".sandbox = {
      method = "bwrap";
      autodetectCliPaths = "existing";  #< for adding a .torrent from disk
      net = "clearnet";
      # TODO: migrate `transmission_passwd` to `secrets` api
      extraPaths = [ "/run/secrets/transmission_passwd" ];
    };

    "sane-scripts.bt-rm".sandbox = {
      method = "bwrap";
      net = "clearnet";
      # TODO: migrate `transmission_passwd` to `secrets` api
      extraPaths = [ "/run/secrets/transmission_passwd" ];
    };

    "sane-scripts.bt-search".sandbox = {
      method = "bwrap";
      net = "clearnet";
      # TODO: migrate `jackett_apikey` to `secrets` api
      extraPaths = [ "/run/secrets/jackett_apikey" ];
    };

    "sane-scripts.bt-show".sandbox = {
      method = "bwrap";
      net = "clearnet";
      # TODO: migrate `transmission_passwd` to `secrets` api
      extraPaths = [ "/run/secrets/transmission_passwd" ];
    };

    # the idea of this script is to `cd` into a fresh clone...
    # but that's an ephemeral operation that would be lost when the sandbox closes.
    "sane-scripts.clone".sandbox.enable = false;

    "sane-scripts.deadlines".sandbox = {
      method = "bwrap";
      extraHomePaths = [ "knowledge/planner/deadlines.tsv" ];
    };

    "sane-scripts.dev-cargo-loop".sandbox = {
      method = "bwrap";
      net = "clearnet";
      whitelistPwd = true;
      extraPaths = [
        # a build script can do a lot... but a well-written one will be confined
        # to XDG dirs and the local dir, and maybe the internet for fetching dependencies.
        ".cache"
        ".config"
        ".local"
      ];
    };

    "sane-scripts.find-dotfiles".sandbox = {
      method = "bwrap";
      extraHomePaths = [
        "/"
        ".persist/ephemeral"
        ".persist/plaintext"
      ];
    };

    "sane-scripts.ip-check".sandbox = {
      method = "landlock";
      net = "all";
    };

    "sane-scripts.ip-port-forward" = {};

    "sane-scripts.private-do".sandbox = {
      # because `mount` is a cap_sys_admin syscall, there's no great way to mount stuff dynamically like this.
      # instead, we put ourselves in a mount namespace, do the mount, and drop into a shell or run a command.
      # this actually has an OK side effect, that the mount isn't shared, and so we avoid contention/interleaving that would cause the ending `umount` to fail.
      method = "bwrap";
      # cap_sys_admin is needed to mount stuff.
      # ordinarily /run/wrappers/bin/mount would do that via setuid, but sandboxes have no_new_privs by default.
      capabilities = [ "sys_admin" ];
      # `sane-private-do` acts as a launcher, so give it access to anything it could possibly need.
      # (crucially, that includes the backing store)
      net = "all";
      extraPaths = [ "/" ];
    };
    "sane-scripts.private-init".sandbox = {
      method = "bwrap";
      capabilities = [ "sys_admin" ];  # it needs to mount the new store
      extraHomePaths = [
        ".persist/private"
      ];
    };
    "sane-scripts.private-lock".sandbox.enable = false;
    "sane-scripts.private-unlock".sandbox.enable = false;

    "sane-scripts.reclaim-boot-space".sandbox = {
      method = "bwrap";
      extraPaths = [ "/boot" ];
    };

    # it's just a thin wrapper around rsync, which is already sandboxed
    "sane-scripts.rcp".sandbox.enable = false;
    # but make sure rsync is always on PATH, so that we actually do get sandboxing :)
    "sane-scripts.rcp".suggestedPrograms = [ "rsync" ];

    "sane-scripts.reboot".sandbox = {
      method = "bwrap";
      whitelistDbus = [
        "system"
      ];
      extraPaths = [
        "/run/systemd"
      ];
    };

    "sane-scripts.reclaim-disk-space".sandbox = {
      method = "bwrap";
      extraPaths = [ "/nix/var/nix" ];
    };

    "sane-scripts.secrets-dump".sandbox.method = "bwrap";
    "sane-scripts.secrets-dump".sandbox.extraHomePaths = [
      ".config/sops"
      "knowledge/secrets"
    ];
    "sane-scripts.secrets-dump".suggestedPrograms = [
      "gnugrep"
      "oath-toolkit"
      "sops"
    ];
    # sane-secrets-update-keys is a thin wrapper around sops + some utilities.
    # really i should sandbox just the utilities
    "sane-scripts.secrets-update-keys".sandbox.enable = false;
    "sane-scripts.secrets-update-keys".suggestedPrograms = [
      "findutils"
      "sops"
    ];

    "sane-scripts.shutdown".sandbox = {
      method = "bwrap";
      whitelistDbus = [
        "system"
      ];
      extraPaths = [
        "/run/systemd"
      ];
    };

    "sane-scripts.stop-all-servo".sandbox = {
      method = "bwrap";
      whitelistDbus = [
        "system"
      ];
      extraPaths = [
        "/run/systemd"
      ];
    };

    # if `tee` isn't trustworthy we have bigger problems
    "sane-scripts.sudo-redirect".sandbox.enable = false;

    "sane-scripts.sync-music" = {};
    "sane-scripts.sync-from-iphone" = {};

    "sane-scripts.tag-media".suggestedPrograms = [
      "exiftool"  #< for (slightly) better sandboxing than default exiftool
    ];
    "sane-scripts.tag-media".sandbox = {
      method = "bwrap";
      autodetectCliPaths = "existing";
      whitelistPwd = true;  # for music renaming
    };

    "sane-scripts.vpn".fs = lib.foldl'
      (acc: vpn:
        let
          vpnCfg = config.sane.vpn."${vpn}";
        in acc // {
          ".config/sane-vpn/vpns/${vpn}".symlink.text = ''
            id=${builtins.toString vpnCfg.id}
            fwmark=${builtins.toString vpnCfg.fwmark}
            priorityMain=${builtins.toString vpnCfg.priorityMain}
            priorityFwMark=${builtins.toString vpnCfg.priorityFwMark}
            addrV4=${vpnCfg.addrV4}
            name=${vpnCfg.name}
            dns=(${lib.concatStringsSep " " vpnCfg.dns})
          '';
        } // (lib.optionalAttrs vpnCfg.isDefault {
          ".config/sane-vpn/default".symlink.text = vpn;
        })
      )
      {}
      (builtins.attrNames config.sane.vpn);
    "sane-scripts.vpn".sandbox = {
      enable = false;  #< bwrap can't handle `ip link`, and landlock can't handle bwrap/pasta for `sane-vpn do`
      # method = "landlock";  #< bwrap can't handle `ip link` stuff even with cap_net_admin
      # net = "all";
      # capabilities = [ "net_admin" ];
      # extraHomePaths = [ ".config/sane-vpn" ];
    };
    "sane-scripts.vpn".suggestedPrograms = [
      "gnugrep"
      "gnused"
      "iproute2"
      "nmcli"
      "sane-scripts.ip-check"
    ];

    "sane-scripts.which".sandbox.method = "bwrap";

    "sane-scripts.wipe".sandbox = {
      method = "bwrap";
      whitelistDbus = [ "user" ];  #< for `secret-tool`
      whitelistS6 = true;  #< for stopping services before wiping
      extraHomePaths = [
        # could be more specific, but at a maintenance cost.
        # TODO: needs updating, now that persisted data lives behind symlinks!
        #       both this list AND the script need patching for that.
        ".cache"
        ".config"
        ".local/share"
        ".librewolf"
        ".mozilla"
        ".persist/ephemeral/.cache"
        ".persist/ephemeral/.config"
        ".persist/ephemeral/.local/share"
        ".persist/ephemeral/.librewolf"
        ".persist/ephemeral/.mozilla"
        ".persist/plaintext/.cache"
        ".persist/plaintext/.config"
        ".persist/plaintext/.local/share"
        ".persist/plaintext/.librewolf"
        ".persist/plaintext/.mozilla"
        ".persist/private/.cache"
        ".persist/private/.config"
        ".persist/private/.local/share"
        ".persist/private/.librewolf"
        ".persist/private/.mozilla"
      ];
    };
    "sane-scripts.wipe".suggestedPrograms = [ "pkill" ];
  };
}
