{ lib, ... }:
{
  services.buffyboard.enable = lib.mkDefault true;
  services.buffyboard.settings.theme.default = "pmos-light";
  services.buffyboard.settings.keyboard.sticky_shift = false;
  # services.buffyboard.settings.quirks.ignore_unused_terminals = true;
  # services.buffyboard.settings.quirks.fbdev_force_refresh = true;
  services.buffyboard.extraFlags = [ "--verbose" ];

  # XXX(2025-10-25): if buffyboard is launched too early in boot, it seems to just exit 0 => force it to always restart.
  # systemd.services.buffyboard.serviceConfig.Restart = "always";
  # systemd.services.buffyboard.serviceConfig.RestartSec = 2;
  # upstream buffyboard service file now ships default `WantedBy=multi-user.target` and `After=getty.target`
  # systemd.services.buffyboard.before = lib.mkForce [];
}
