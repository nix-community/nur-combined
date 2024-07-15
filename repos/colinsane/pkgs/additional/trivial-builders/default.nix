{ lib
, deepLinkIntoOwnPackage
, rmDbusServicesInPlace
, runCommandLocalOverridable
, stdenv
, symlinkJoin
}:
{
  # like `runCommandLocal`, but can be `.overrideAttrs` and supports standard phases/hooks like `postBuild`, etc.
  runCommandLocalOverridable = name: env: buildPhase: stdenv.mkDerivation {
    inherit name;
    preferLocalBuild = true;
    dontUnpack = true;

    buildPhase = lib.concatStringsSep "\n" [
      "runHook preBuild"
      buildPhase
      "runHook postBuild"
      "runHook postInstall"
      "runHook postFixup"
    ];
  };
  # given some package and a path, extract the item at `${package}/${path}` into
  # its own package, but otherwise keeping the same path.
  # this is done by copying the bits, so as to avoid including the item's neighbors
  # in its runtime closure.
  copyIntoOwnPackage = pkg: path: let
    paths = if lib.isList path then path else [ path ];
    suffix = (lib.head paths) + (if paths != [ path ] then "-and-other-paths" else "");
  in
    runCommandLocalOverridable "${pkg.pname or pkg.name}-${suffix}" { } ''
      for item in ${lib.escapeShellArgs paths}; do
        mkdir -p "$out/$(dirname $item)"
        cp -a "${pkg}/$item" "$out/$item"
      done
    '';

  linkIntoOwnPackage = pkg: path: let
    paths = if lib.isList path then path else [ path ];
    suffix = (lib.head paths) + (if paths != [ path ] then "-and-other-paths" else "");
  in
    runCommandLocalOverridable "${pkg.pname or pkg.name}-${suffix}" { } ''
      for item in ${lib.escapeShellArgs paths}; do
        mkdir -p "$out/$(dirname $item)"
        ln -s "${pkg}/$item" "$out/$item"
      done
    '';

  deepLinkIntoOwnPackage = pkg: symlinkJoin {
    name = pkg.pname or pkg.name;
    paths = [ pkg ];
    meta = pkg.meta or {};
    postBuild = ''
      runHook postBuild
      runHook postInstall
      runHook postFixup
    '';
  };

  # given some package, create a new package which symlinks every file of the original
  # *except* for its dbus files.
  # in addition, edit its .desktop files to clarify that it can't be "dbus activated".
  rmDbusServices = pkg: rmDbusServicesInPlace (deepLinkIntoOwnPackage pkg);

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
