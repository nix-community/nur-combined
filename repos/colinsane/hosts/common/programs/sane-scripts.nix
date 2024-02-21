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
      "sane-scripts.private-change-passwd"
      "sane-scripts.private-do"
      "sane-scripts.private-init"
      "sane-scripts.private-lock"
      "sane-scripts.private-unlock"
      "sane-scripts.rcp"
      "sane-scripts.reboot"
      "sane-scripts.reclaim-boot-space"
      "sane-scripts.reclaim-disk-space"
      "sane-scripts.secrets-dump"
      "sane-scripts.secrets-unlock"
      "sane-scripts.secrets-update-keys"
      "sane-scripts.shutdown"
      "sane-scripts.sudo-redirect"
      "sane-scripts.tag-music"
      "sane-scripts.vpn"
      "sane-scripts.which"
      "sane-scripts.wipe"
    ];
    "sane-scripts.sys-utils" = declPackageSet [
      "sane-scripts.ip-port-forward"
      "sane-scripts.sync-music"
    ];

    "sane-scripts.bt-add".sandbox = {
      method = "bwrap";
      wrapperType = "wrappedDerivation";
      net = "clearnet";
      # TODO: migrate `transmission_passwd` to `secrets` api
      extraPaths = [ "/run/secrets/transmission_passwd" ];
    };

    "sane-scripts.bt-rm".sandbox = {
      method = "bwrap";
      wrapperType = "wrappedDerivation";
      net = "clearnet";
      # TODO: migrate `transmission_passwd` to `secrets` api
      extraPaths = [ "/run/secrets/transmission_passwd" ];
    };

    "sane-scripts.bt-search".sandbox = {
      method = "bwrap";
      wrapperType = "wrappedDerivation";
      net = "clearnet";
      # TODO: migrate `jackett_apikey` to `secrets` api
      extraPaths = [ "/run/secrets/jackett_apikey" ];
    };

    "sane-scripts.bt-show".sandbox = {
      method = "bwrap";
      wrapperType = "wrappedDerivation";
      net = "clearnet";
      # TODO: migrate `transmission_passwd` to `secrets` api
      extraPaths = [ "/run/secrets/transmission_passwd" ];
    };

    # the idea of this script is to `cd` into a fresh clone...
    # but that's an ephemeral operation that would be lost when the sandbox closes.
    "sane-scripts.clone".sandbox.enable = false;

    "sane-scripts.deadlines".sandbox = {
      method = "bwrap";
      wrapperType = "wrappedDerivation";
      extraHomePaths = [ "knowledge/planner/deadlines.tsv" ];
    };

    "sane-scripts.dev-cargo-loop".sandbox = {
      method = "bwrap";
      wrapperType = "wrappedDerivation";
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
      wrapperType = "wrappedDerivation";
      extraHomePaths = [
        ".cache"
        ".config"
        ".local"
        # would be nice to give it everything *except* ~/private, but not currently possible
        ".bitmonero"
        ".electrum"
        ".librewolf"
        ".ssh"
        ".steam"
        ".wine"
      ];
    };

    "sane-scripts.ip-check".sandbox = {
      method = "landlock";
      wrapperType = "wrappedDerivation";
      net = "all";
    };

    # TODO: gocryptfs/fuse requires /run/wrappers/bin/fusermount3 SUID
    # "sane-scripts.private-unlock".sandbox = {
    #   method = "landlock";
    #   wrapperType = "wrappedDerivation";
    #   extraHomePaths = [ "private" ];
    #   # TODO: don't hardcode the username here.
    #   extraPaths = [ "/nix/persist/home/colin/private" ];
    # };

    "sane-scripts.reclaim-boot-space".sandbox = {
      method = "bwrap";
      wrapperType = "wrappedDerivation";
      extraPaths = [ "/boot" ];
    };

    # it's just a thin wrapper around rsync, which is already sandboxed
    "sane-scripts.rcp".sandbox.enable = false;
    # but make sure rsync is always on PATH, so that we actually do get sandboxing :)
    "sane-scripts.rcp".suggestedPrograms = [ "rsync" ];

    "sane-scripts.reboot".sandbox = {
      method = "bwrap";
      wrapperType = "wrappedDerivation";
      extraPaths = [
        "/run/dbus"
        "/run/systemd"
      ];
    };

    "sane-scripts.reclaim-disk-space".sandbox = {
      method = "bwrap";
      wrapperType = "wrappedDerivation";
      extraPaths = [ "/nix/var/nix" ];
    };

    "sane-scripts.secrets-unlock".sandbox = {
      method = "bwrap";
      wrapperType = "wrappedDerivation";
      extraHomePaths = [
        ".ssh/id_ed25519"
        ".ssh/id_ed25519.pub"
        ".config/sops"
      ];
    };

    # sane-secrets-dump is a thin wrapper around sops + some utilities.
    # really i should sandbox just the utilities
    "sane-scripts.secrets-dump".sandbox.enable = false;
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
      wrapperType = "wrappedDerivation";
      extraPaths = [
        "/run/dbus"
        "/run/systemd"
      ];
    };

    # if `tee` isn't trustworthy we have bigger problems
    "sane-scripts.sudo-redirect".sandbox.enable = false;

    "sane-scripts.tag-music".sandbox = {
      method = "bwrap";
      wrapperType = "wrappedDerivation";
      autodetectCliPaths = "existing";
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
            bridgeDevice=${vpnCfg.bridgeDevice}
            dns=(${lib.concatStringsSep " " vpnCfg.dns})
          '';
        } // (lib.optionalAttrs vpnCfg.isDefault {
          ".config/sane-vpn/default".symlink.text = vpn;
        })
      )
      {}
      (builtins.attrNames config.sane.vpn);
    "sane-scripts.vpn".sandbox = {
      method = "landlock";  #< bwrap can't handle `ip link` stuff even with cap_net_admin
      wrapperType = "wrappedDerivation";
      net = "all";
      capabilities = [ "net_admin" ];
      extraHomePaths = [ ".config/sane-vpn" ];
    };

    "sane-scripts.which".sandbox = {
      method = "bwrap";
      wrapperType = "wrappedDerivation";
      extraHomePaths = [
        # for SXMO
        ".config/sxmo/hooks"
      ];
    };

    "sane-scripts.wipe".sandbox = {
      method = "bwrap";
      wrapperType = "wrappedDerivation";
      whitelistDbus = [ "user" ];  #< for `secret-tool` and `systemd --user stop <service>
      extraHomePaths = [
        # could be more specific, but at a maintenance cost.
        ".cache"
        ".config"
        ".local/share"
        ".librewolf"
        ".mozilla"
      ];
    };
  };
}
