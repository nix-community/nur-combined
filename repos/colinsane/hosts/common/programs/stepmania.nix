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
#
# N.B.: you MUST launch this from ~/.stepmania-5.1.
{ config, ... }:
let
  cfg = config.sane.programs.stepmania;
in
{
  sane.programs.stepmania = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "inplace";  #< non-standard packaging; binary lives at $out/stepmania-5.1/stepmania  (not even in an /opt dir)
    sandbox.whitelistAudio = true;
    sandbox.whitelistDri = true;
    sandbox.whitelistX = true;
    sandbox.extraPaths = [
      # for the pad input (/dev/input/js*)
      "/dev/input"
      "/sys/class/input"
    ];

    persist.byStore.plaintext = [
      ".stepmania-5.1/Cache"  #< otherwise gotta index all the songs every launch
      ".stepmania-5.1/Save"
    ];

    # TODO: setup ~/.stepmania-5.1/Themes
    fs.".stepmania-5.1/Courses".symlink.target = "/mnt/servo/media/games/stepmania/Courses";
    fs.".stepmania-5.1/Songs".symlink.target = "/mnt/servo/media/games/stepmania/Songs";
    fs.".stepmania-5.1/stepmania.nix".symlink.target = "../nixos/hosts/common/programs/stepmania.nix";

    # stepmania expects the current working directory to be the same directory where all its data resides.
    # so, we have to link these all in and then the user must launch it from ~/.stepmania-5.1.
    # TODO: wrap stepmania with a `cd ~/.stepmania-5.1`, and move all these to `~/.local/share/stepmania`
    fs.".stepmania-5.1/Announcers".symlink.target = "${cfg.package}/stepmania-5.1/Announcers";
    fs.".stepmania-5.1/BackgroundEffects".symlink.target = "${cfg.package}/stepmania-5.1/BackgroundEffects";
    fs.".stepmania-5.1/BackgroundTransitions".symlink.target = "${cfg.package}/stepmania-5.1/BackgroundTransitions";
    fs.".stepmania-5.1/BGAnimations".symlink.target = "${cfg.package}/stepmania-5.1/BGAnimations";
    fs.".stepmania-5.1/Characters".symlink.target = "${cfg.package}/stepmania-5.1/Characters";
    fs.".stepmania-5.1/Data".symlink.target = "${cfg.package}/stepmania-5.1/Data";
    fs.".stepmania-5.1/Docs".symlink.target = "${cfg.package}/stepmania-5.1/Docs";
    fs.".stepmania-5.1/NoteSkins".symlink.target = "${cfg.package}/stepmania-5.1/NoteSkins";
    fs.".stepmania-5.1/Scripts".symlink.target = "${cfg.package}/stepmania-5.1/Scripts";
    fs.".stepmania-5.1/Themes".symlink.target = "${cfg.package}/stepmania-5.1/Themes";
  };
}
