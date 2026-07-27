{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
{
  options.eownerdead.run0 = mkEnableOption (mdDoc ''
    Use systemd-run0 instead of sudo.
  '');

  config = mkIf config.eownerdead.run0 {
    # https://discourse.nixos.org/t/run0-not-working-right/62772/6
    security.pam.services.systemd-run0 = { };
    # security.sudo.enable = mkDefault false;
  };
}
