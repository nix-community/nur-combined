{ config, pkgs, ... }:
{
  sane.programs.wireplumber = {
    packageUnwrapped = pkgs.wireplumber.override {
      # use the same pipewire as configured to run against.
      pipewire = config.sane.programs.pipewire.packageUnwrapped;
    };

    sandbox.method = "bunpen";
    # sandbox.whitelistDbus = [
    #   "system"  #< so it can request better scheduling from rtkit
    #   # "user"  #< apparently not needed?
    # ];
    sandbox.whitelistAudio = true;
    sandbox.extraPaths = [
      # i think these video inputs (for e.g. webcam) are optional.
      "/dev/media0"
      "/dev/snd"
      # vvv video* is for moby
      "/dev/video0"
      "/dev/video1"
      "/dev/video2"
      # "/run/systemd"
      "/run/udev"
      "/sys/class/sound"
      "/sys/class/video4linux"
      "/sys/devices"
    ];
    # sandbox.isolatePids = false;  #< needed if i want rtkit to grant this higher scheduling priority

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
