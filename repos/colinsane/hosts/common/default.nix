{ lib, pkgs, ... }:
{
  imports = [
    ./feeds.nix
    ./fs.nix
    ./hardware
    ./home
    ./hostnames.nix
    ./hosts.nix
    ./ids.nix
    ./machine-id.nix
    ./net.nix
    ./nix-path
    ./persist.nix
    ./programs
    ./secrets.nix
    ./ssh.nix
    ./users
    ./vpn.nix
  ];

  sane.nixcache.enable-trusted-keys = true;
  sane.nixcache.enable = lib.mkDefault true;
  sane.persist.enable = lib.mkDefault true;
  sane.root-on-tmpfs = lib.mkDefault true;
  sane.programs.sysadminUtils.enableFor.system = lib.mkDefault true;
  sane.programs.consoleUtils.enableFor.user.colin = lib.mkDefault true;

  nixpkgs.config.allowUnfree = true;  # NIXPKGS_ALLOW_UNFREE=1
  nixpkgs.config.allowBroken = true;  # NIXPKGS_ALLOW_BROKEN=1

  # time.timeZone = "America/Los_Angeles";
  time.timeZone = "Etc/UTC";  # DST is too confusing for me => use a stable timezone

  nix.extraOptions = ''
    # see: `man nix.conf`
    # useful when a remote builder has a faster internet connection than me
    builders-use-substitutes = true  # default: false
    # maximum seconds to wait when connecting to binary substituter
    connect-timeout = 3  # default: 0
    # download-attempts = 5  # default: 5
    # allow `nix flake ...` command
    experimental-features = nix-command flakes
    # whether to build from source when binary substitution fails
    fallback = true  # default: false
    # whether to keep building dependencies if any other one fails
    keep-going = true  # default: false
    # whether to keep build-only dependencies of GC roots (e.g. C compiler) when doing GC
    keep-outputs = true  # default: false
    # how many lines to show from failed build
    log-lines = 30  # default: 10
    # narinfo-cache-negative-ttl = 3600  # default: 3600
    # whether to use ~/.local/state/nix/profile instead of ~/.nix-profile, etc
    use-xdg-base-directories = true  # default: false
    # whether to warn if repository has uncommited changes
    warn-dirty = false  # default: true
  '';
  # hardlinks identical files in the nix store to save 25-35% disk space.
  # unclear _when_ this occurs. it's not a service.
  # does the daemon continually scan the nix store?
  # does the builder use some content-addressed db to efficiently dedupe?
  nix.settings.auto-optimise-store = true;
  # TODO: see if i can remove this?
  nix.settings.trusted-users = [ "root" ];

  services.journald.extraConfig = ''
    # docs: `man journald.conf`
    # merged journald config is deployed to /etc/systemd/journald.conf
    [Journal]
    # disable journal compression because the underlying fs is compressed
    Compress=no
  '';

  systemd.services.nix-daemon.serviceConfig = {
    # the nix-daemon manages nix builders
    # kill nix-daemon subprocesses when systemd-oomd detects an out-of-memory condition
    # see:
    # - nixos PR that enabled systemd-oomd: <https://github.com/NixOS/nixpkgs/pull/169613>
    # - systemd's docs on these properties: <https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#ManagedOOMSwap=auto%7Ckill>
    #
    # systemd's docs warn that without swap, systemd-oomd might not be able to react quick enough to save the system.
    # see `man oomd.conf` for further tunables that may help.
    #
    # alternatively, apply this more broadly with `systemd.oomd.enableSystemSlice = true` or `enableRootSlice`
    # TODO: also apply this to the guest user's slice (user-1100.slice)
    # TODO: also apply this to distccd
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMSwap = "kill";
  };


  system.activationScripts.nixClosureDiff = {
    supportsDryActivation = true;
    text = ''
      # show which packages changed versions or are new/removed in this upgrade
      # source: <https://github.com/luishfonseca/dotfiles/blob/32c10e775d9ec7cc55e44592a060c1c9aadf113e/modules/upgrade-diff.nix>
      # modified to not error on boot (when /run/current-system doesn't exist)
      if [ -d /run/current-system ]; then
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      fi
    '';
  };
  system.activationScripts.notifyActive = {
    text = ''
      # send a notification to any sway users logged in, that the system has been activated/upgraded.
      # this probably doesn't work if more than one sway session exists on the system.
      _notifyActiveSwaySock="$(echo /run/user/*/sway-ipc.*.sock)"
      if [ -e "$_notifyActiveSwaySock" ]; then
        SWAYSOCK="$_notifyActiveSwaySock" ${pkgs.sway}/bin/swaymsg -- exec \
          "${pkgs.libnotify}/bin/notify-send 'nixos activated' 'version: $(cat $systemConfig/nixos-version)'"
      fi
    '';
  };

  # disable non-required packages like nano, perl, rsync, strace
  environment.defaultPackages = [];

  # dconf docs: <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/desktop_migration_and_administration_guide/profiles>
  # this lets programs temporarily write user-level dconf settings (aka gsettings).
  # they're written to ~/.config/dconf/user, unless `DCONF_PROFILE` is set to something other than the default of /etc/dconf/profile/user
  # find keys/values with `dconf dump /`
  programs.dconf.enable = true;
  programs.dconf.packages = [
    (pkgs.writeTextFile {
      name = "dconf-user-profile";
      destination = "/etc/dconf/profile/user";
      text = ''
        user-db:user
        system-db:site
      '';
    })
  ];
  # sane.programs.glib.enableFor.user.colin = true;  # for `gsettings`

  # link debug symbols into /run/current-system/sw/lib/debug
  # hopefully picked up by gdb automatically?
  environment.enableDebugInfo = true;
}
