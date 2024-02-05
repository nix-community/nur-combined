{ pkgs, ... }:
{
  sane.programs.handbrake = {
    sandbox.method = "bwrap";  #< landlock would be better (prevents output to tmp dirs), but needs work for /mnt/servo-media to function.
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.extraHomePaths = [
      "Music"
      "Pictures"  # i have some videos in there too.
      "Videos"
      "tmp"
    ];
    sandbox.extraPaths = [
      "/mnt/servo-media/Pictures"
      "/mnt/servo-media/Videos"
    ];
    sandbox.autodetectCliPaths = true;

    # disable expensive sambda dependency; i don't use it.
    packageUnwrapped = pkgs.handbrake.override {
      ffmpeg_5-full = pkgs.ffmpeg_5-full.override {
        withSamba = false;
      };
    };
  };
}
