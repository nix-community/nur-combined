self: pkgs:

let inherit (self) callPackage; in let
  inherit (pkgs.lib) breakDrv getVersion mapIf versionAtLeast;

  needsNewCargoHash = let
    minVersion = "1.39.0";
    isOutdated = versionAtLeast minVersion (getVersion pkgs.cargo or "");
  in mapIf breakDrv isOutdated;
in {

  # applications {{{1
  # applications.graphics {{{2

  shotgun = needsNewCargoHash
    (callPackage ../applications/graphics/shotgun { });

  # tools {{{1
  # tools.misc {{{2

  hacksaw = needsNewCargoHash
    (callPackage ../tools/misc/hacksaw { });

  # }}}1

}
# vim:fdm=marker:fdl=1
