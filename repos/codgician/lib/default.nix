{ pkgs }:

with pkgs.lib; {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};

  # Get packages with upgrade script
  getPackagesWithUpdateScript = filterAttrs
    (k: v: v?passthru && v.passthru?updateScript)
    (import ../pkgs { inherit pkgs; });
}
