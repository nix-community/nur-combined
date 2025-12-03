{ config, lib, pkgs, ... }:
{
  imports = [
    ./boot.nix
    ./feeds.nix
    ./fs
    ./home
    ./hosts.nix
    ./ids.nix
    ./machine-id.nix
    ./net
    ./nix.nix
    ./polyunfill.nix
    ./programs
    ./quirks.nix
    ./secrets.nix
    ./snapper.nix
    ./ssh.nix
    ./systemd.nix
    ./users
  ];


  # docs: https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  # this affects where nixos modules look for stateful data which might have been migrated across releases.
  system.stateVersion = "21.11";

  sane.nixcache.enable-trusted-keys = true;
  sane.nixcache.enable = lib.mkDefault true;
  sane.persist.enable = lib.mkDefault true;
  sane.root-on-tmpfs = lib.mkDefault true;
  sane.programs.sysadminUtils.enableFor.system = lib.mkDefault true;
  sane.programs.sysadminExtraUtils.enableFor.system = lib.mkDefault true;
  sane.programs.consoleUtils.enableFor.user.colin = lib.mkDefault true;

  services.buffyboard.enable = lib.mkDefault true;
  services.buffyboard.settings.theme.default = "pmos-light";
  # services.buffyboard.settings.quirks.ignore_unused_terminals = true;
  # services.buffyboard.settings.quirks.fbdev_force_refresh = true;
  services.buffyboard.extraFlags = [ "--verbose" ];
  # XXX(2025-10-25): if buffyboard is launched too early in boot, it seems to just exit 0 => force it to always restart.
  # systemd.services.buffyboard.serviceConfig.Restart = "always";
  # systemd.services.buffyboard.serviceConfig.RestartSec = 2;
  # upstream buffyboard service file now ships default `WantedBy=multi-user.target` and `After=getty.target`
  # systemd.services.buffyboard.before = lib.mkForce [];

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
        ${lib.getExe pkgs.nvd} --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      fi
    '';
  };

  # link debug symbols into /run/current-system/sw/lib/debug
  # hopefully picked up by gdb automatically?
  environment.enableDebugInfo = true;

  # enable manpages targeted at developers (i.e. `devman` package outputs)
  # <https://search.nixos.org/options?channel=unstable&show=documentation.dev.enable&query=documentation.dev>
  documentation.dev.enable = true;
  # document my own, custom (non-nixpkgs) options in `man configuration.nix`:
  documentation.nixos = lib.mkIf (config.sane.maxBuildCost >= 3) {
    includeAllModules = true;
    options.warningsAreErrors = false;  #< TODO: fix all my options to have `description`, then enable.
  };
}
