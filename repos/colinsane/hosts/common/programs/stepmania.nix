# configuration:
# - things like calibration data live in ~/.stepmania-5.1/Save/Preferences.ini
# - GlobalOffsetSeconds = difference between audio and video delay.
#   Hit F6 twice in-game to being auto calibration
#   Usually the result will be negative (i.e. the higher the latency of the pad, the more negative the offset)
# - SoundDevice: use pacmd list-sources and select alsa_output.pci-xxxxx
# - VisualOffset: if video is coming LATE, then use a negative number
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
  sane.programs.stepmania = {
    persist.plaintext = [
      ".stepmania-5.1/Cache"  #< otherwise gotta index all the songs every launch
      ".stepmania-5.1/Save"
    ];
    fs.".stepmania-5.1/Courses".symlink.target = "/mnt/servo-media/games/stepmania/Courses";
    fs.".stepmania-5.1/Songs".symlink.target = "/mnt/servo-media/games/stepmania/Songs";
    # TODO: setup ~/.stepmania-5.1/Themes
  };
}
