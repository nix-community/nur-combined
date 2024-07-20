{ config, pkgs, ... }:
{
  imports = [
    ./fs.nix
  ];

  sane.roles.client = true;
  sane.roles.dev-machine = true;
  sane.roles.pc = true;
  sane.services.wg-home.enable = true;
  sane.services.wg-home.ip = config.sane.hosts.by-name."lappy".wg-home.ip;
  sane.ovpn.addrV4 = "172.23.119.72";
  # sane.ovpn.addrV6 = "fd00:0000:1337:cafe:1111:1111:0332:aa96/128";

  # sane.guest.enable = true;
  sane.image.extraBootFiles = [ pkgs.bootpart-uefi-x86_64 ];

  sane.programs.stepmania.enableFor.user.colin = true;
  sane.programs.sway.enableFor.user.colin = true;

  sane.programs.geary.config.autostart = true;
  sane.programs.signal-desktop.config.autostart = true;

  sops.secrets.colin-passwd.neededForUsers = true;

  sane.services.rsync-net.enable = true;

  # default config: https://man.archlinux.org/man/snapper-configs.5
  # defaults to something like:
  #   - hourly snapshots
  #   - auto cleanup; keep the last 10 hourlies, last 10 daylies, last 10 monthlys.
  services.snapper.configs.nix = {
    # TODO: for the impermanent setup, we'd prefer to just do /nix/persist,
    # but that also requires setting up the persist dir as a subvol
    SUBVOLUME = "/nix";
    ALLOW_USERS = [ "colin" ];
  };
}
