{ lib, pkgs, ... }:
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
  sane.programs.consoleUtils.enableFor.user.colin = lib.mkDefault true;

  sane.services.buffyboard.enable = true;
  sane.services.buffyboard.settings.theme.default = "pmos-light";
  # sane.services.buffyboard.settings.quirks.fbdev_force_refresh = true;
  sane.services.buffyboard.extraFlags = [ "--verbose" ];

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
}
