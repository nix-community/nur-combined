self: pkgs:

let inherit (self) callPackage; in let
  inherit (pkgs.lib) breakDrv getVersion mapIf versionOlder;

  needsNewCargoHash = let
    minVersion = "1.41.0";
    isOutdated = versionOlder minVersion (getVersion pkgs.cargo or "");
  in mapIf breakDrv isOutdated;
in {

  # applications {{{1
  # applications.graphics {{{2

  shotgun = needsNewCargoHash
    (callPackage ../applications/graphics/shotgun { });

  shotgun-unstable = needsNewCargoHash
    (callPackage ../applications/graphics/shotgun/unstable.nix { });

  # tools {{{1
  # tools.misc {{{2

  hacksaw = self.hacksaw-unstable;

  hacksaw-unstable = needsNewCargoHash
    (callPackage ../tools/misc/hacksaw/unstable.nix { });

  uniconize = needsNewCargoHash
    (callPackage ../tools/misc/uniconize { });

  uniconize-unstable = needsNewCargoHash
    (callPackage ../tools/misc/uniconize/unstable.nix { });

  # }}}1

}
# vim:fdm=marker:fdl=1
