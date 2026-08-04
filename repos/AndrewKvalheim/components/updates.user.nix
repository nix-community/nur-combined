{ lib, pkgs, ... }:

let
  inherit (lib) getExe;
  inherit (pkgs) may-upgrade writeShellApplication;

  wait-for-system = writeShellApplication {
    name = "wait-for-system";
    text = ''
      sleep '5s' # Resolve race

      while systemctl is-active --quiet 'nixos-upgrade.service'; do
        # shellcheck disable=SC2016
        echo 'Yielding to `nixos-upgrade.service`…' >&2
        sleep '1m'
      done
    '';
  };
in
{
  services.home-manager.autoUpgrade = {
    enable = true;
    frequency = "06:00 America/Los_Angeles";
  };

  systemd.user.services.home-manager-auto-upgrade = {
    Unit.ConditionACPower = true;

    Service = {
      ExecCondition = getExe may-upgrade;
      ExecStartPre = getExe wait-for-system;
    };
  };
}
