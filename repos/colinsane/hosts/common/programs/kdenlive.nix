{ pkgs, ... }:
{
  sane.programs.kdenlive = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.extraHomePaths = [
      "Music"
      "Pictures"  # i have some videos in there too.
      "Pictures/servo-macros"
      "Videos"
      "Videos/servo"
      "tmp"
    ];
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  # notifications
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;

    packageUnwrapped = pkgs.kdenlive.override {
      ffmpeg-full = pkgs.ffmpeg-full.override {
        # avoid expensive samba build for a feature i don't use
        withSamba = false;
      };
    };
  };
}
