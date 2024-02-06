{ pkgs, ... }:
{
  sane.programs.handbrake = {
    sandbox.method = "landlock";  #< also supports bwrap, but landlock ensures we don't write to non-mounted tmpfs dir
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
    sandbox.autodetectCliPaths = true;

    # disable expensive sambda dependency; i don't use it.
    packageUnwrapped = pkgs.handbrake.override {
      ffmpeg_5-full = pkgs.ffmpeg_5-full.override {
        withSamba = false;
      };
    };
  };
}
