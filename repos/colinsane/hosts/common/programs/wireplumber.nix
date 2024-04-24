{ ... }:
{
  sane.programs.wireplumber = {
    sandbox.method = "bwrap";
    # sandbox.whitelistDbus = [
    #   "system"  #< so it can request better scheduling from rtkit
    #   # "user"  #< TODO: is this needed?
    # ];
    sandbox.whitelistAudio = true;
    sandbox.extraPaths = [
      # i think these video inputs (for e.g. webcam) are optional.
      "/dev/media0"
      "/dev/snd"
      "/dev/video0"
      "/dev/video1"
      "/dev/video2"
      "/run/systemd"
      "/run/udev"
      "/sys/class/sound"
      "/sys/class/video4linux"
      "/sys/devices"
    ];
    # sandbox.extraConfig = [
    #   # needed if i want rtkit to grant this higher scheduling priority
    #   "--sane-sandbox-keep-namespace" "pid"
    # ];

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
