{ pkgs }:

with pkgs.lib; {
  # list names of all subdirectories in a dir
  listSubdirNames = dir:
    builtins.attrNames (
      filterAttrs
        (n: v: v == "directory")
        (builtins.readDir dir)
    );

  # list paths of all subdirectories in a dir
  listSubdirPaths = dir: map (x: dir + "/${x}") (listSubdirNames dir);
}
