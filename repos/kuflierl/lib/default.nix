{ pkgs }:

with pkgs.lib;
{
  pkgPathByName =
    name:
    (path.append ../. (
      path.subpath.join [
        "pkgs"
        "by-name"
        (builtins.substring 0 2 name)
        name
        "package.nix"
      ]
    ));
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
}
