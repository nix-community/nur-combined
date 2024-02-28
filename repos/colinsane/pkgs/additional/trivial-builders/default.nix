{ runCommandLocal
, rmDbusServicesInPlace
, symlinkJoin
}:
{
  # given some package and a path, extract the item at `${package}/${path}` into
  # its own package, but otherwise keeping the same path.
  # this is done by copying the bits, so as to avoid including the item's neighbors
  # in its runtime closure.
  copyIntoOwnPackage = pkg: path: runCommandLocal "${pkg.pname or pkg.name}-${path}" {
    env.item = path;
    env.fromPkg = pkg;
  } ''
    mkdir -p "$out/$(dirname "$item")"
    cp -a "$fromPkg/$item" "$out/$item"
    runHook postFixup
  '';

  linkIntoOwnPackage = pkg: path: runCommandLocal "${pkg.pname or pkg.name}-${path}" {
    env.item = path;
    env.fromPkg = pkg;
  } ''
    mkdir -p "$out/$(dirname "$item")"
    ln -s "$fromPkg/$item" "$out/$item"
    runHook postFixup
  '';

  # given some package, create a new package which symlinks every file of the original
  # *except* for its dbus files.
  # in addition, edit its .desktop files to clarify that it can't be "dbus activated".
  rmDbusServices = pkg: rmDbusServicesInPlace (symlinkJoin {
    name = pkg.name or pkg.pname;
    paths = [ pkg ];
    postBuild = ''
      runHook postFixup
    '';
  });

  # like rmDbusServices, but do it by patching the derivation instead of wrapping it.
  # unlike `rmDbusServices`, this won't work on *all* derivation types (e.g. runCommand), so you should
  # check the output to see it's what you want.
  rmDbusServicesInPlace = pkg: pkg.overrideAttrs (base: {
    postFixup = (base.postFixup or "") + ''
      rm -rf $out/share/dbus-1
      for d in $out/share/applications/*.desktop; do
        if substitute "$d" ./substituteResult --replace-fail DBusActivatable=true DBusActivatable=false; then
          mv ./substituteResult "$d"
        fi
      done
    '';
  });
}
