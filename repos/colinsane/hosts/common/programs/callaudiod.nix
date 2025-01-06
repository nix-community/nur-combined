# https://gitlab.com/mobian1/callaudiod
# device support:
# - moby:
#   - mic muting works fine
#   - speaker seems to have zero volume (maybe it's my alsa profiles?)
#   - shows some failures when only the modem is online (no wifi)
#     - gnome-calls doesn't even create an output audio stream, for example; and the other end of the call can't hear any mic.
# - desko: unsupported. no mic muting, etc.
#   - "Card 'alsa_card.pci-0000_0b_00.1' lacks speaker and/or earpiece port, skipping"
#   - "callaudiod-pulse-CRITICAL **: 07:45:48.092: No suitable card found, stopping here..."
{ pkgs, ... }:
{
  sane.programs.callaudiod = {
    packageUnwrapped = pkgs.rmDbusServices pkgs.callaudiod;

    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user = true;  #< TODO: reduce

    services.callaudiod = {
      description = "callaudiod: dbus service to switch audio profiles and mute microphone";
      partOf = [ "default" ];
      command = "callaudiod";
    };
  };
}
