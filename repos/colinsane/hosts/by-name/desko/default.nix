{ config, pkgs, ... }:
{
  imports = [
    ./fs.nix
  ];

  sane.services.hickory-dns.asSystemResolver = false;  # TEMPORARY: TODO: re-enable hickory-dns
  # sane.programs.devPkgs.enableFor.user.colin = true;
  # sane.guest.enable = true;

  # don't enable wifi by default: it messes with connectivity.
  # systemd.services.iwd.enable = false;
  # networking.wireless.enable = false;
  # systemd.services.wpa_supplicant.enable = false;
  # sane.programs.wpa_supplicant.enableFor.user.colin = lib.mkForce false;
  # sane.programs.wpa_supplicant.enableFor.system = lib.mkForce false;
  # don't auto-connect to wifi networks
  # see: <https://networkmanager.dev/docs/api/latest/NetworkManager.conf.html#device-spec>
  networking.networkmanager.unmanaged = [ "type:wifi" ];

  sops.secrets.colin-passwd.neededForUsers = true;

  sane.roles.build-machine.enable = true;
  sane.roles.client = true;
  sane.roles.pc = true;
  sane.services.ollama.enable = true;
  sane.services.wg-home.enable = true;
  sane.services.wg-home.ip = config.sane.hosts.by-name."desko".wg-home.ip;
  sane.ovpn.addrV4 = "172.26.55.21";
  # sane.ovpn.addrV6 = "fd00:0000:1337:cafe:1111:1111:20c1:a73c";
  sane.services.rsync-net.enable = true;

  sane.nixcache.remote-builders.desko = false;

  sane.programs.firefox.config.formFactor = "desktop";

  sane.programs.sane-private-unlock-remote.enableFor.user.colin = true;
  sane.programs.sane-private-unlock-remote.config.hosts = [ "servo" ];

  sane.programs.sway.enableFor.user.colin = true;
  sane.programs.steam.enableFor.user.colin = true;

  sane.programs.nwg-panel.config = {
    battery = false;
    brightness = false;
  };

  sane.programs.mpv.config.defaultProfile = "high-quality";

  sane.image.extraBootFiles = [ pkgs.bootpart-uefi-x86_64 ];

  # needed to use libimobiledevice/ifuse, for iphone sync
  services.usbmuxd.enable = true;

  hardware.amdgpu.opencl.enable = true;  # desktop (AMD's opencl implementation AKA "ROCM"); probably required for ollama

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
