{ lib, pkgs, ... }:
{
  imports = [
    ./feeds.nix
    ./fs.nix
    ./hardware
    ./home
    ./hosts.nix
    ./ids.nix
    ./machine-id.nix
    ./net
    ./nix
    ./persist.nix
    ./polyunfill.nix
    ./programs
    ./secrets.nix
    ./ssh.nix
    ./systemd.nix
    ./users
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
      _notifyActiveSwaySock="$(echo /run/user/*/sway-ipc*.sock)"
      if [ -e "$_notifyActiveSwaySock" ]; then
        SWAYSOCK="$_notifyActiveSwaySock" ${pkgs.sway}/bin/swaymsg -- exec \
          "${pkgs.libnotify}/bin/notify-send 'nixos activated' 'version: $(cat $systemConfig/nixos-version)'"
      fi
    '';
  };

  # link debug symbols into /run/current-system/sw/lib/debug
  # hopefully picked up by gdb automatically?
  environment.enableDebugInfo = true;
}
