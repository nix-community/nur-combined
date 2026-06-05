# itgmania is a (slightly) better-maintained fork of stepmania
# - <https://github.com/itgmania/itgmania>
#
# configuration:
# - things like calibration data live in ~/.itgmania/Save/Preferences.ini
#   - GlobalOffsetSeconds = difference between audio and video delay.
#     Hit F6 twice in-game to being auto calibration
#     Usually the result will be negative (i.e. the higher the latency of the pad, the more negative the offset)
#   - SoundDevice: use `pactl list sources` (or `pacmd list-sources`) and select alsa_output.pci-xxxxx
#       e.g. `alsa_output.pci-0000_00_1f.3.hdmi-surround.monitor`
#   - VisualOffset: if video is coming LATE, then use a negative number
#
# songs/packs:
# - find pad packs:
#   - <https://docs.google.com/spreadsheets/d/1F1IURV1UAYiICTLhAOKIJfwUN1iG12ZOufHZuDKiP48/edit#gid=27038621>
#   - https://www.reddit.com/r/Stepmania/comments/aku3lb/best_pad_packs_on_stepmaniaonlinenet_or_elsewhere/
#   - https://fitupyourstyle.com/
#     allows search by difficulty
# - dl packs from <https://stepmaniaonline.net>
{ ... }:
{
  sane.programs.itgmania = {
    buildCost = 1;

    sandbox.whitelistAudio = true;
    sandbox.whitelistDri = true;
    sandbox.whitelistX = true;  #< XXX(2025-05-01): neither QT_QPA_PLATFORM=wayland nor SDL_VIDEODRIVER=wayland work; X11 is required
    sandbox.extraPaths = [
      # for the pad input (/dev/input/js*)
      "/dev/input"
      "/sys/class/input"
    ];
    # on launch, itgmania will copy templates for any missing files out of its data directory and into ~/.itgmania
    sandbox.extraHomePaths = [
      ".itgmania"
    ];

    persist.byStore.plaintext = [
      ".itgmania/Cache"  #< otherwise gotta index all the songs every launch
      ".itgmania/Save"   #< Save/Preferences.ini (esp: GlobalOffsetSeconds)
    ];

    # TODO: setup ~/.local/share/itgmania/Themes
    fs.".itgmania/Courses".symlink.target = "/mnt/servo/media/games/stepmania/Courses";
    fs.".itgmania/Songs".symlink.target = "/mnt/servo/media/games/stepmania/Songs";
  };
}
