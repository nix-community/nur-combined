{ config, pkgs, ... }:
{
  imports = [
    ./fs.nix
  ];

  sane.roles.client = true;
  sane.roles.pc = true;
  sane.services.wg-home.enable = true;
  sane.services.wg-home.ip = config.sane.hosts.by-name."lappy".wg-home.ip;
  sane.ovpn.addrV4 = "172.23.119.72";
  # sane.ovpn.addrV6 = "fd00:0000:1337:cafe:1111:1111:0332:aa96/128";

  # sane.guest.enable = true;
  sane.image.extraBootFiles = [ pkgs.bootpart-uefi-x86_64 ];

  sane.programs.sane-private-unlock-remote.enableFor.user.colin = true;
  sane.programs.sane-private-unlock-remote.config.hosts = [ "servo" ];

  sane.programs.firefox.config.formFactor = "laptop";
  sane.programs.itgmania.enableFor.user.colin = true;
  # sane.programs.stepmania.enableFor.user.colin = true;  #< TODO: fix build
  sane.programs.sway.enableFor.user.colin = true;

  sops.secrets.colin-passwd.neededForUsers = true;

  sane.services.rsync-net.enable = true;

  # starting 2024/09, under default settings (apparently 256 quantum), audio would crackle under load.
  # 1024 solves *most* crackles, but still noticable under heavier loads.
  sane.programs.pipewire.config.min-quantum = 2048;

  # TODO: enable snapper (need to make `/nix` or `/nix/persist` a subvolume, somehow).
  # default config: https://man.archlinux.org/man/snapper-configs.5
  # defaults to something like:
  #   - hourly snapshots
  #   - auto cleanup; keep the last 10 hourlies, last 10 daylies, last 10 monthlys.
  # to list snapshots: `sudo snapper --config nix list`
  # to take a snapshot: `sudo snapper --config nix create`
  # services.snapper.configs.nix = {
  #   # TODO: for the impermanent setup, we'd prefer to just do /nix/persist,
  #   # but that also requires setting up the persist dir as a subvol
  #   SUBVOLUME = "/nix";
  #   # TODO: ALLOW_USERS doesn't seem to work. still need `sudo snapper -c nix list`
  #   ALLOW_USERS = [ "colin" ];
  # };
}
