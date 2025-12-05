{ config, lib, ... }:
{
  imports = [
    ./fs.nix
  ];

  # firewall has to be open to allow clients to use services hosted on this device,
  # like `ollama`
  sane.ports.openFirewall = true;

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
  sane.roles.work = true;
  sane.services.ollama.enable = lib.mkIf (config.sane.maxBuildCost >= 3) true;
  sane.services.wg-home.enable = true;
  sane.ovpn.addrV4 = "172.26.55.21";
  # sane.ovpn.addrV6 = "fd00:0000:1337:cafe:1111:1111:20c1:a73c";
  sane.services.rsync-net.enable = true;

  sane.nixcache.remote-builders.desko = false;

  sane.programs.claude-code.enableFor.user.colin = true;

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

  # needed to use libimobiledevice/ifuse, for iphone sync
  services.usbmuxd.enable = true;

  hardware.amdgpu.opencl.enable = true;  # desktop (AMD's opencl implementation AKA "ROCM"); probably required for ollama
}
