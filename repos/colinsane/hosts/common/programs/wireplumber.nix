{ ... }:
{
  sane.programs.wireplumber = {
    sandbox.method = "bwrap";
    sandbox.whitelistDbus = [
      # i think this isn't strictly necessary; it just wants to ask the portal for realtime perms
      # "system"
      "user"
    ];
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
