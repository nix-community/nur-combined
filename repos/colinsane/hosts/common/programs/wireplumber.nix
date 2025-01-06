{ config, pkgs, ... }:
{
  sane.programs.wireplumber = {
    packageUnwrapped = pkgs.wireplumber.override {
      # use the same pipewire as configured to run against.
      pipewire = config.sane.programs.pipewire.packageUnwrapped;
    };

    # sandbox.whitelistDbus.system = true;  #< so it can request better scheduling from rtkit
    sandbox.whitelistDbus.user = true;  #< required for camera sharing, especially through xdg-desktop-portal, e.g. `snapshot` application  (TODO: reduce)
    sandbox.whitelistAudio = true;
    sandbox.whitelistAvDev = true;
    # sandbox.keepPids = true;  #< needed if i want rtkit to grant this higher scheduling priority
    # sandbox.net = "all";  #< needed if you want to plug audio devices at runtime (udev; AF_NETLINK)

    suggestedPrograms = [ "alsa-ucm-conf" ];

    persist.byStore.plaintext = [
      # persist per-device volume levels
      ".local/state/wireplumber"
    ];

    services.wireplumber = {
      description = "wireplumber: pipewire Multimedia Service Session Manager";
      depends = [ "pipewire" ];
      partOf = [ "sound" ];
      command = "wireplumber";
    };
  };
}
