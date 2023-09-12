{ symlinkJoin }:
{
  # given some package, create a new package which symlinks every file of the original
  # *except* for its dbus files.
  rmDbusServices = pkg: symlinkJoin {
    name = pkg.name or pkg.pname;
    paths = [ pkg ];
    postBuild = ''
      rm -rf $out/share/dbus-1
    '';
  };
}
