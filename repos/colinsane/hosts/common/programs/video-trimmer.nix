{ ... }:
{
  sane.programs.video-trimmer = {
    sandbox.extraHomePaths = [
      "Music"
      "Pictures/from"  # e.g. Videos taken from my phone
      "Videos/local"
      "Videos/servo"
      "tmp"
    ];
    sandbox.autodetectCliPaths = "parent";  #< it opens $1 and common use is to output to the same directory
    sandbox.whitelistAudio = true;
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.mesaCacheDir = ".cache/video-trimmer/mesa";  # TODO: is this the correct app-id?
  };
}
