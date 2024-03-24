{ pkgs, ... }:
{
  sane.programs.handbrake = {
    sandbox.method = "landlock";  #< also supports bwrap, but landlock ensures we don't write to non-mounted tmpfs dir
    sandbox.whitelistDbus = [ "user" ];  # notifications
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "Music"
      "Pictures/from"  # e.g. videos filmed from my phone
      "Videos/local"
      "Videos/servo"
      "tmp"
    ];
    sandbox.autodetectCliPaths = true;

    # disable expensive sambda dependency; i don't use it.
    packageUnwrapped = pkgs.handbrake.override {
      ffmpeg-full = pkgs.ffmpeg-full.override {
        withSamba = false;
      };
    };
  };
}
