{ config, lib, pkgs, ... }:
{
  imports = [
    ../modules
    ../../modules
    ./apparmor.nix
    ./boot.nix
    ./buffyboard.nix
    ./feeds.nix
    ./fs
    ./home
    ./hosts.nix
    ./ids.nix
    ./machine-id.nix
    ./net
    ./nix.nix
    ./oom.nix
    ./polyunfill.nix
    ./programs
    ./quirks.nix
    ./secrets.nix
    ./snapper.nix
    ./ssh.nix
    ./systemd.nix
    ./users
  ];

  nixpkgs.config.allowUnfree = true;  # NIXPKGS_ALLOW_UNFREE=1
  nixpkgs.config.allowBroken = true;  # NIXPKGS_ALLOW_BROKEN=1
  nixpkgs.config.allowUnsupportedSystem = true;  # NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1
  # fetchedSourceNameDefault = "versioned" (mass rebuild): place src paths at /nix/store/$hash-$name-$version instead of $hash-source
  # nixpkgs.config.fetchedSourceNameDefault = "versioned";

  # docs: https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  # this affects where nixos modules look for stateful data which might have been migrated across releases.
  system.stateVersion = "21.11";

  sane.nixcache.enable-trusted-keys = true;
  sane.nixcache.enable = lib.mkDefault true;
  sane.persist.enable = lib.mkDefault true;
  sane.root-on-tmpfs = lib.mkDefault true;
  sane.programs.coreShellUtils.enableFor.system = lib.mkDefault true;
  sane.programs.sysadminUtils.enableFor.system = lib.mkDefault true;
  sane.programs.consoleUtils.enableFor.user.colin = lib.mkDefault true;

  # irqbalance monitors interrupt count (as a daemon) and assigns high-frequency interrupts to different CPUs.
  # that reduces contention between simultaneously-fired interrupts.
  services.irqbalance.enable = true;

  # time.timeZone = "America/Los_Angeles";
  time.timeZone = "Etc/UTC";  # DST is too confusing for me => use a stable timezone

  system.activationScripts.nixClosureDiff = {
    supportsDryActivation = true;
    text = ''
      # show which packages changed versions or are new/removed in this upgrade
      # source: <https://github.com/luishfonseca/dotfiles/blob/32c10e775d9ec7cc55e44592a060c1c9aadf113e/modules/upgrade-diff.nix>
      # modified to not error on boot (when /run/current-system doesn't exist)
      if [ -d /run/current-system ]; then
        ${lib.getExe pkgs.nvd} --nix-bin-dir=${config.sane.programs.nix.package}/bin diff /run/current-system "$systemConfig"
      fi
    '';
  };

  # link debug symbols into /run/current-system/sw/lib/debug
  # hopefully picked up by gdb automatically?
  environment.enableDebugInfo = true;

  # enable manpages targeted at developers (i.e. `devman` package outputs)
  # <https://search.nixos.org/options?channel=unstable&show=documentation.dev.enable&query=documentation.dev>
  documentation.dev.enable = lib.mkDefault true;
  # document my own, custom (non-nixpkgs) options in `man configuration.nix`:
  documentation.nixos = lib.mkIf (config.sane.maxBuildCost >= 3) {
    includeAllModules = true;
    options.warningsAreErrors = false;  #< TODO: fix all my options to have `description`, then enable.
  };

  system.forbiddenDependenciesRegexes = [
    # XXX(2026-01-15): i'm working my way to a perl-less system especially because of cross-compilation woes;
    # xdg-utils was a major source of perl; "forbid" it to avoid regressing.
    # this really ought to be a warning, though.
    "^/nix/store/................................-xdg-utils"
  ];
}
