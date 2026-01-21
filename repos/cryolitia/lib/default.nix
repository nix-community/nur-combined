{ pkgs }:

with pkgs.lib;
rec {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  isBuildable = platform: p: (((!(p.meta ? broken)) || !p.meta.broken) && (meta.availableOn { system = platform; } p));
  isCacheable = p: !(p.preferLocalBuild or false);

  filterNurAttrs =
    platform: attrs:
    filterAttrs (_: v: isDerivation v && isBuildable platform v && isCacheable v) attrs;
}
