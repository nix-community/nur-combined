{ lib, ... }:
{
  imports = [
    ./fs.nix
  ];

  sane.roles.client = true;
  sane.roles.pc = true;
  sane.services.wg-home.enable = true;
  # sane.ovpn.addrV4 = "172.23.119.72";
  # sane.ovpn.addrV6 = "fd00:0000:1337:cafe:1111:1111:0332:aa96/128";

  # sane.guest.enable = true;

  sane.programs.sane-private-unlock-remote.enableFor.user.colin = true;
  sane.programs.sane-private-unlock-remote.config.hosts = [ "servo" ];

  sane.programs.firefox.config.formFactor = "laptop";
  sane.programs.itgmania.enableFor.user.colin = true;
  sane.programs.sway.enableFor.user.colin = true;

  sops.secrets.colin-passwd.neededForUsers = true;

  sane.services.rsync-net.enable = true;

  # starting 2024/09, under default settings (apparently 256 quantum), audio would crackle under load.
  # 1024 solves *most* crackles, but still noticable under heavier loads.
  sane.programs.pipewire.config.min-quantum = 2048;

  # limit how many snapshots we keep, due to extremely limited disk space (TODO: remove this override after upgrading lappy hard drive)
  services.snapper.configs.root.TIMELINE_LIMIT_HOURLY = lib.mkForce 2;
  services.snapper.configs.root.TIMELINE_LIMIT_DAILY = lib.mkForce 2;
  services.snapper.configs.root.TIMELINE_LIMIT_WEEKLY = lib.mkForce 0;
  services.snapper.configs.root.TIMELINE_LIMIT_MONTHLY = lib.mkForce 0;
  services.snapper.configs.root.TIMELINE_LIMIT_YEARLY = lib.mkForce 0;
}
