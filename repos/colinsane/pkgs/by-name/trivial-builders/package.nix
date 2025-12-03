{
  lib,
  deepLinkIntoOwnPackage,
  linkIntoOwnPackage,
  rmDbusServicesInPlace,
  runCommandLocalOverridable,
  stdenvNoCC,
  symlinkJoin,
}:
{
  # like `runCommandLocal`, but can be `.overrideAttrs` and supports standard phases/hooks like `postBuild`, etc.
  runCommandLocalOverridable = name: env: buildPhase: stdenvNoCC.mkDerivation ({
    inherit name;
    preferLocalBuild = true;
    dontUnpack = true;

    buildPhase = lib.concatStringsSep "\n" [
      "runHook preBuild"
      buildPhase
      "runHook postBuild"
    ];
  } // env);

  writeSymlink = { buildInputs ? [], escapeContents ? true, doCheck ? null }: contents: file: stdenvNoCC.mkDerivation {
    name = "symlink-${file}";
    env = {
      inherit contents file;
      escapeContents = if escapeContents then "1" else "";
    };

    dontUnpack = true;

    buildPhase = ''
      betterContents=
      tryContents() {
        local try="$1"
        if [[ -n "$betterContents" ]]; then
          return
        fi

        if [[ -e "$try" ]]; then
          betterContents="$try"
        fi
      }

      set -x
      if [[ "''${contents:0:1}" != "/" ]]; then
        for p in $buildInputs; do
          if [[ -z "$escapeContents" ]]; then
            tryContents $p/$contents
          else
            tryContents "$p/$contents"
          fi
        done
      elif [[ -z "$escapeContents" ]]; then
        tryContents $contents
      fi

      if [[ -n "$betterContents" ]]; then
        contents="$betterContents"
      fi
    '';

    checkPhase = ''
      (
        set -x
        test -e "$contents"
      )
    '';

    installPhase = ''
      (
        set -x
        mkdir -p $(dirname "$out/$file")
        ln -s "$contents" "$out/$file"
      )
    '';

    inherit buildInputs;

    doCheck = if doCheck != null then doCheck else buildInputs != [];
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

  # link a subset of `pkg` (a single package, or an array of packages) into its own derivation.
  # no paths are renamed or "lifted up" to a new root -- the new derivation is just a subset of the old.
  linkIntoOwnPackage = pkg: path: { separateDoc ? null, separateMan ? null, ...}@args: let
    paths = if lib.isList path then path else [ path ];
    suffix = (lib.head paths) + (if paths != [ path ] then "-and-other-paths" else "");
    separateMan' = if separateMan == null then
      builtins.any (p: lib.hasPrefix "share/man" p) paths
    else
      separateMan;
    separateDoc' = if separateDoc == null then
      builtins.any (p: lib.hasPrefix "share/doc" p) paths
    else
      separateDoc;
  in
    runCommandLocalOverridable "${pkg.pname or pkg.name}-${suffix}" ({
      outputs = [ "out" ] ++ lib.optionals separateMan' [ "man" ] ++ lib.optionals separateDoc' [ "doc" ];
      inputs = pkg.all;
      pathsToLink = paths;
      configurePhase = ''
        runHook preConfigure

        # all vars supplied by nix are str, so convert -> array
        concatTo pathsToLink_ pathsToLink
        pathsToLink=("''${pathsToLink_[@]}")
        unset pathsToLink_
        concatTo inputs_ inputs
        inputs=("''${inputs_[@]}")
        unset inputs_

        runHook postConfigure
      '';
    } // args) ''
      # check if $1/$2 exists, and if so, link it into $out/$2.
      # $2 may be a glob.
      tryLink() {
        local input=$1
        local relPath=$2
        local srcPaths=("$input"/$relPath)

        local failedToLink=
        for srcPath in "''${srcPaths[@]}"; do
          if [[ -e "$srcPath" ]]; then
            local relPath=''${srcPath/"$input"/}
            local dirName=$(dirname "$relPath")
            mkdir -p "$out/$dirName" && ln -s "$srcPath" "$out/$relPath"
          else
            failedToLink=1
          fi
        done
        test -z "$failedToLink"
      }
      tryLinkFromAnyInput() {
        local item=$1
        local linked=
        for toplevel in "''${inputs[@]}"; do
          if tryLink "$toplevel" "$item"; then
            linked=1
          fi
        done
        test -n "$linked" || echo "failed to link $item" >&2
      }

      for item in "''${pathsToLink[@]}"; do
        tryLinkFromAnyInput "$item"
      done
    '';

  # `linkBinIntoOwnPackage myPkg "binary-name"`
  # `linkBinIntoOwnPackage myPkg [ "cli-tool1" "cli-tool2" ]`
  # `linkBinIntoOwnPackage myPkg [ ]`  -> link *all* of bin/
  #
  # in addition, all manpages/docs are linked into the output
  linkBinIntoOwnPackage = pkg: path: let
    path' = if path == [] then "" else path;  #< if handed an empty list, then link all of `bin`
    paths = if lib.isList path' then path else [ path' ];  #< coerce to list
    paths' = [
      # we can't always tell which files under here are associated with a _particular_ binary,
      # so link them all
      "share/doc"
      # note the `*`; man sections are almost always just 1-8, however there is occasionally a suffix (e.g. `1p` for posix binaries)
      # "share/man/man0*"  # non-standard; only used by posix headers (0p)?
      # "share/man/man1*"  # binaries
      # "share/man/man2*"  # system calls
      # "share/man/man3*"  # library functions
      "share/man/man4*"  # special files
      "share/man/man5*"  # file formats
      "share/man/man6*"  # games
      "share/man/man7*"  # misc
      # "share/man/man8*" # sysadmin commands
      # "share/man/man9*"  # kernel routines
    ] ++ (lib.concatMap
      (p: [
        "bin/${p}"
        # XXX: this is i18n-unaware; doesn't link `share/man/$lang/man1/$binName.1`
        "share/man/man1*/${p}"    # binaries (without the .1 or .gz suffix; TODO: does anything actually match this?)
        "share/man/man1*/${p}.*"  # binaries
        "share/man/man8*/${p}"    # sysadmin commands (without the .8 or .gz suffix; TODO: does anything actually match this?)
        "share/man/man8*/${p}.*"  # sysadmin commands
      ])
      paths
    )
    ;
  in
    linkIntoOwnPackage pkg paths' {
      postInstallCheck = ''
        # assert that there's *something* in `bin/`
        # if there isn't, the wildcard won't expand, and the `test -x` will fail.
        binFiles=($out/bin/*)
        for f in "''${binFiles[@]}"; do
          test -x "$f"
        done
      '';
      postFixup = ''
        # not all packages ship manpages or docs,
        # but we can't know if that's the case upfront, generically.
        mkdir -p "$doc" "$man"
      '';
    }
  ;

  deepLinkIntoOwnPackage = pkg: { outputs ? [ "out" ] }: symlinkJoin {
    name = pkg.pname or pkg.name;
    paths = builtins.map (output: pkg."${output}") outputs;
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
  rmDbusServices = pkg: rmDbusServicesInPlace (deepLinkIntoOwnPackage pkg {});

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
