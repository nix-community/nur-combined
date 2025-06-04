{ pkgs, ... }:
{
  imports = [
    ./fs.nix
  ];

  sane.roles.client = true;
  sane.roles.pc = true;
  sane.roles.work = true;
  sane.services.wg-home.enable = true;
  # sane.ovpn.addrV4 = "172.23.119.72";

  # sane.guest.enable = true;
  sane.image.extraBootFiles = [ pkgs.bootpart-uefi-x86_64 ];

  # sane.programs.sane-private-unlock-remote.enableFor.user.colin = true;
  # sane.programs.sane-private-unlock-remote.config.hosts = [ "servo" ];

  sane.programs.firefox.config.formFactor = "laptop";
  sane.programs.itgmania.enableFor.user.colin = true;
  sane.programs.sway.enableFor.user.colin = true;

  sops.secrets.colin-passwd.neededForUsers = true;

  # sane.services.rsync-net.enable = true;
}
