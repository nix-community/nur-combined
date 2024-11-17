# use like:
# ```
#   $ lftp ftps://uninsane.org`
#   lftp ~> ls
#   ...
#   lftp -> get README.me
#   exit
# ```
{ ... }:
{
  sane.programs.lftp = {
    sandbox.net = "all";
    sandbox.extraPaths = [
      "Music"
      "Videos/local"
      "Videos/servo"
      "tmp"
    ];
    sandbox.whitelistPwd = true;  #< it's very common to upload/DL to/from the current folder
  };
}
