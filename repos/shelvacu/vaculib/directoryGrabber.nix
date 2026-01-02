{ lib, ... }:
let
  removeDotNix =
    s:
    let
      l = builtins.stringLength s;
      lastFour = builtins.substring (l - 4) (-1) s;
    in
    assert lastFour == ".nix";
    builtins.substring 0 (l - 4) s;

  directoryGrabberImpl =
    {
      path, # the path to load files from, almost always ./.
      mainName ? null, # the name for the file to load in each directory including the .nix; null for none (ie default.nix)
    }:
    let
      directoryListing = builtins.removeAttrs (builtins.readDir path) [ "default.nix" ];
    in
    assert builtins.isPath path;
    lib.mapAttrs' (
      k: v:
      assert v == "directory" || v == "regular";
      {
        name = if v == "directory" then k else removeDotNix k;
        value =
          if v == "directory" then
            (if mainName == null then /${path}/${k} else /${path}/${k}/${mainName})
          else
            /${path}/${k};
      }
    ) directoryListing;
in
rec {
  directoryGrabber =
    arg: if builtins.isPath arg then directoryGrabberImpl { path = arg; } else directoryGrabberImpl arg;

  directoryGrabberList = arg: builtins.attrValues (directoryGrabber arg);
}
