{ lib, pkgs, ... }:

let
  inherit (lib) getExe;
  inherit (pkgs) may-upgrade nix openssh writeShellApplication;

  update-channels = writeShellApplication {
    name = "update-channels";
    runtimeInputs = [ nix openssh ];
    text = "nix-channel --update";
  };
in
{
  system.autoUpgrade = {
    enable = true;
    dates = "06:00 America/Los_Angeles";
  };

  systemd.services.nixos-upgrade = {
    unitConfig.ConditionACPower = true;
    onFailure = [ "alert@%N.service" ];

    serviceConfig = {
      ExecCondition = getExe may-upgrade;
      ExecStartPre = getExe update-channels;
    };
  };
}
