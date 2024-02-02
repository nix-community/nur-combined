{ pkgs, ... }:
{
  sane.programs.handbrake = {
    # disable expensive sambda dependency; i don't use it.
    packageUnwrapped = pkgs.handbrake.override {
      ffmpeg_5-full = pkgs.ffmpeg_5-full.override {
        withSamba = false;
      };
    };
  };
}
