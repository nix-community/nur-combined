{ ... }:
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
      method = "bwrap";
      wrapperType = "wrappedDerivation";
      net = "clearnet";
    };

    # TODO: is `sane-reclaim-boot-space` broken?
    # "sane-scripts.reclaim-boot-space".sandbox = {
    #   method = "bwrap";
    #   wrapperType = "wrappedDerivation";
    #   extraPaths = [ "/boot" ];
    # };

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
