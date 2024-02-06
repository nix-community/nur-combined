{ pkgs, ... }:
{
  sane.programs.kdenlive = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.extraHomePaths = [
      "Music"
      "Pictures"  # i have some videos in there too.
      "Videos"
      "tmp"
    ];
    sandbox.extraPaths = [
      "/mnt/servo/media/Pictures"
      "/mnt/servo/media/Videos"
    ];
    sandbox.whitelistDri = true;
    packageUnwrapped = pkgs.kdenlive.override {
      ffmpeg-full = pkgs.ffmpeg-full.override {
        # avoid expensive samba build for a feature i don't use
        withSamba = false;
      };
    };
  };
}
