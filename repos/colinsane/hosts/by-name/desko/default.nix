{ config, lib, ... }:
{
  imports = [
    ../../common
    ./fs.nix
  ];

  networking.hostName = "desko";
  sane.cpu = lib.mkDefault "x86_64";

  # firewall has to be open to allow clients to use services hosted on this device,
  # like `llama-cpp`
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

  sane.roles.build-machine.enable = true;
  sane.roles.client = true;
  sane.roles.pc = true;
  sane.roles.work = true;
  sane.services.llama-cpp.enable = lib.mkIf (config.sane.maxBuildCost >= 2) true;
  sane.services.wg-home.enable = true;
  sane.ovpn.addrV4 = "172.26.55.21";
  # sane.ovpn.addrV6 = "fd00:0000:1337:cafe:1111:1111:20c1:a73c";
  sane.services.rsync-net.enable = true;

  sane.nixcache.remote-builders.desko = false;

  sane.programs.firefox.config.formFactor = "desktop";

  sane.programs.sane-private-unlock-remote.enableFor.user.colin = true;
  sane.programs.sane-private-unlock-remote.config.hosts = [ "servo" ];

  sane.programs.sway.enableFor.user.colin = true;
  sane.programs.pcGameApps.suggestedPrograms = [
    "steam"
  ];

  sane.programs.nwg-panel.config = {
    battery = false;
    brightness = false;
  };
  sane.programs.waybar.config = {
    modules.battery = false;
  };

  sane.programs.mpv.config.defaultProfile = "high-quality";

  # needed to use libimobiledevice/ifuse, for iphone sync
  services.usbmuxd.enable = true;
}
