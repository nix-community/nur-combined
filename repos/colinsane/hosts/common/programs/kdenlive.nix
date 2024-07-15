{ pkgs, ... }:
{
  sane.programs.kdenlive = {
    packageUnwrapped = pkgs.kdenlive.override {
      ffmpeg-full = pkgs.ffmpeg-full.override {
        # avoid expensive samba build for a feature i don't use
        withSamba = false;
      };
    };

    buildCost = 1;

    sandbox.method = "bwrap";
    sandbox.extraHomePaths = [
      "Music"
      "Pictures/from"  # e.g. Videos taken from my phone
      "Pictures/servo-macros"
      "Videos/local"
      "Videos/servo"
      "tmp"
    ];
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  # notifications
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
  };
}
