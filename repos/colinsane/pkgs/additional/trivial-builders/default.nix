{ symlinkJoin }:
{
  # given some package, create a new package which symlinks every file of the original
  # *except* for its dbus files.
  # in addition, edit its .desktop files to clarify that it can't be "dbus activated".
  rmDbusServices = pkg: symlinkJoin {
    name = pkg.name or pkg.pname;
    paths = [ pkg ];
    postBuild = ''
      rm -rf $out/share/dbus-1
      for d in $out/share/applications/*.desktop; do
        if substitute "$d" ./substituteResult --replace-fail DBusActivatable=true DBusActivatable=false; then
          mv ./substituteResult "$d"
        fi
      done
    '';
  };
}
