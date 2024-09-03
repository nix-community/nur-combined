# note a BUG:
# - when changing the desired output type, that doesn't apply to any files you've already added.
#   best to close & reopen soundconverter after changing the desired file type
{ ... }:
{
  sane.programs.soundconverter = {
    buildCost = 1;
    sandbox.method = "bunpen";
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "Music"
      "tmp"
      "use"
      ".config/dconf"
    ];
    sandbox.whitelistDbus = [ "user" ];  # for dconf
    sandbox.extraPaths = [
      "/mnt/servo/media/Music"
      "/mnt/servo/media/games"
    ];
    sandbox.autodetectCliPaths = "existingOrParent";
  };
}
