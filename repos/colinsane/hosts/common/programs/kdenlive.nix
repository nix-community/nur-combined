{ pkgs, ... }:
{
  sane.programs.kdenlive = {
    packageUnwrapped = pkgs.kdenlive.override {
      ffmpeg-full = pkgs.ffmpeg-full.override {
        # avoid expensive samba build for a feature i don't use
        withSamba = false;
      };
    };
  };
}
