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
{ lib, pkgs, ... }:
{
  sane.programs.itgmania = {
    buildCost = 1;

    packageUnwrapped = pkgs.itgmania.overrideAttrs (upstream: {
      # XXX(2024-12-29): itgmania (and stepmania) have to be run from their bin directory, else they silently exit
      nativeBuildInputs = upstream.nativeBuildInputs ++ [
        pkgs.makeWrapper
      ];
      postInstall = lib.replaceStrings
        [ "ln -s $out/itgmania/itgmania $out/bin/itgmania" ]
        [ "makeWrapper $out/itgmania/itgmania $out/bin/itgmania --run 'cd ${placeholder "out"}/itgmania'" ]
        upstream.postInstall
      ;
    });

    sandbox.whitelistAudio = true;
    sandbox.whitelistDri = true;
    sandbox.whitelistX = true;  #< TODO: is this needed? try QT_QPA_PLATFORM=wayland or SDL_VIDEODRIVER=wayland
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
      ".itgmania/Save"
    ];

    # TODO: setup ~/.local/share/itgmania/Themes
    fs.".itgmania/Courses".symlink.target = "/mnt/servo/media/games/stepmania/Courses";
    fs.".itgmania/Songs".symlink.target = "/mnt/servo/media/games/stepmania/Songs";
  };
}
