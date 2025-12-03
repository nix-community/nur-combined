{
  lib,
  stdenv,
  buildPackages,
  bunpen,
  file,
  gnugrep,
  gnused,
  linkFarm,
  makeBinaryWrapper,
  makeShellWrapper,
  runCommand,
  writeShellScriptBin,
  xorg,
}:
let
  fakeSaneSandboxed = writeShellScriptBin bunpen.meta.mainProgram ''
    # behave like the real bunpen with BUNPEN_DISABLE=1,
    # but in a manner which avoids taking a dependency on the real bunpen.
    # the primary use for this is to allow a package's `check` phase to work even when bunpen isn't available (which allows for faster iteration).
    _origArgs=($@)

    # throw away all arguments until we find the path to the binary which is being sandboxed
    while [ "$#" -gt 0 ] && ! [[ "$1" =~ /\.sandboxed/ ]]; do
      shift
    done
    if [ "$#" -eq 0 ]; then
      >&2 echo "${bunpen.meta.mainProgram} (mock): failed to parse args: ''${_origArgs[*]}"
      exit 1
    fi

    if [ -z "$BUNPEN_DISABLE" ]; then
      >&2 echo "${bunpen.meta.mainProgram} (mock): not called with BUNPEN_DISABLE=1; unsure how to sandbox: ''${_origArgs[*]}"
      exit 1
    fi
    # assume that every argument after the binary name is an argument for the binary and not for the sandboxer.
    exec "$@"
  '';

  makeHookable = pkg: pkg.overrideAttrs (drv: lib.optionalAttrs (drv ? buildCommand && !lib.hasInfix "postFixup" drv.buildCommand) {
    buildCommand = drv.buildCommand + ''
      runHook postFixup
    '';
  });

  # take an existing package, which may have a `bin/` folder as well as `share/` etc,
  # and patch the `bin/` items in-place
  sandboxBinariesInPlace = bunpen': extraSandboxArgs: pkgName: pkg: pkg.overrideAttrs (unwrapped: {
    # disable the sandbox and inject a minimal fake sandboxer which understands that flag,
    # in order to support packages which invoke sandboxed apps in their check phase.
    # note that it's not just for packages which invoke their *own* binaries in check phase,
    # but also packages which invoke OTHER PACKAGES' sandboxed binaries.
    # hence, put the fake sandbox in nativeBuildInputs instead of nativeCheckInputs.
    env = (unwrapped.env or {}) // {
      BUNPEN_DISABLE = 1;
    };
    outputs = unwrapped.outputs or [ "out" ];
    nativeBuildInputs = [
      # the ordering here is specific: inject our deps BEFORE the unwrapped program's
      # so that the unwrapped's take precendence and we limit interference (e.g. makeWrapper impl)
      fakeSaneSandboxed
      gnugrep
      makeBinaryWrapper
      makeShellWrapper
    ] ++ (unwrapped.nativeBuildInputs or []);
    # XXX(2025-01-28): i think nativeBuildInputs aren't on PATH during installCheck phase?
    # so add the fake sandboxer here too to make version checks work
    nativeCheckInputs = [
      fakeSaneSandboxed
    ];
    nativeInstallCheckInputs = [
      fakeSaneSandboxed
    ];
    disallowedReferences = (unwrapped.disallowedReferences or []) ++ [
      # the fake sandbox gates itself behind BUNPEN_DISABLE, so if it did end up deployed
      # then it wouldn't permit anything not already permitted. but it would still be annoying.
      fakeSaneSandboxed
    ];

    postFixup = (unwrapped.postFixup or "") + ''
      assertExecutable() {
        :  # my programs refer to bunpen by name, not path, which triggers an over-eager assertion in nixpkgs (so, mask that)
      }
      makeDocumentedCWrapper() {
        # this is identical to nixpkgs' implementation, only replace execv with execvp, the latter which looks for the executable on PATH.
        local src=$(makeCWrapper "$@")
        src="''${src/return execv(/return execvp(}"
        local docs=$(docstring "$@")
        printf '%s\n\n' "$src"
        printf '%s\n' "$docs"
      }

      sandboxWrap() {
        local _dir="$1"
        local _name="$2"
        echo "sandboxWrap $_dir/$_name"

        # N.B.: unlike stock `wrapProgram`, we place the unwrapped binary in a subdirectory and *preserve its name*.
        # the upside of this is that for applications which read "$0" to decide what to do (e.g. busybox, git)
        # they work as expected without any special hacks.
        # though even so, the sandboxer still tries to preserve the $0 which it was invoked under
        mkdir -p "$_dir/.sandboxed"
        if [[ "$(readlink $_dir/$_name)" =~ ^\.\./ ]]; then
          # relative links which ascend a directory (into a non-bin/ directory)
          # won't point to the right place if we naively move them
          ln -s "../$(readlink $_dir/$_name)" "$_dir/.sandboxed/$_name"
          rm "$_dir/$_name"
        else
          mv "$_dir/$_name" "$_dir/.sandboxed/"
        fi

        makeBinaryWrapper ${bunpen'} "$_dir/$_name" \
          --suffix PATH : /run/current-system/sw/libexec/${bunpen.pname} \
          --inherit-argv0 \
          ${lib.escapeShellArgs (lib.flatten (builtins.map (f: [ "--add-flag" f ]) extraSandboxArgs))} \
          --add-flag "$_dir/.sandboxed/$_name"
      }

      derefWhileInSameOutput() {
        local output="$1"
        local item="$2"
        if [ -L "$item" ]; then
          local target=$(readlink "$item")
          if [[ "$target" =~ ^"$output"/ ]]; then
            # absolute link back into the same package
            item=$(derefWhileInSameOutput "$output" "$target")
          elif [[ "$target" =~ ^/nix/store/ ]]; then
            : # absolute link to another package: we're done
          else
            # relative link
            local parent=$(dirname "$item")
            target="$parent/$target"
            item=$(derefWhileInSameOutput "$output" "$target")
          fi
        fi
        # canonicalize the path, to avoid wrapping the same item twice under different names
        realpath --no-symlinks "$item"
      }
      findUnwrapped() {
        if [ -L "$1" ]; then
          echo "$1"
        else
          local dir_=$(dirname "$1")
          local file_=$(basename "$1")
          local sandboxed="$dir_/.sandboxed/$file_"
          local unwrapped="$dir_/.''${file_}-unwrapped"
          if grep -q "$sandboxed" "$1"; then
            echo "/dev/null"  #< already sandboxed
          elif grep -q "$unwrapped" "$1"; then
            echo $(findUnwrapped "$unwrapped")
          else
            echo "$1"
          fi
        fi
      }

      crawlAndWrap() {
        local output="$1"
        local _dir="$2"
        nixDebugLog "crawlAndWrap $_dir"
        local items=($(ls -a "$_dir/"))
        for item in "''${items[@]}"; do
          if [ "$item" != . ] && [ "$item" != .. ]; then
            local target="$_dir/$item"
            if [ -d "$target" ]; then
              crawlAndWrap "$output" "$target"
            elif [ -x "$target" ] && [[ "$item" != .* ]]; then
              # in the case of symlinks, deref until we find the real file, or the symlink points outside the package
              target=$(derefWhileInSameOutput "$output" "$target")
              target=$(findUnwrapped "$target")
              if [ "$target" != /dev/null ]; then
                local parent=$(dirname "$target")
                local bin=$(basename "$target")
                sandboxWrap "$parent" "$bin"
              fi
            fi
            # ignore all non-binaries or "hidden" binaries (to avoid double-wrapping)
          fi
        done
      }

      for output in $outputs; do
        local outdir=''${!output}
        echo "scanning output '$output' at $outdir for binaries to sandbox"
        if [ -e "$outdir/bin" ]; then
          crawlAndWrap "$outdir" "$outdir/bin"
        fi
        if [ -e "$outdir/libexec" ]; then
          crawlAndWrap "$outdir" "$outdir/libexec"
        fi
      done
    '';
  });

  # there are certain `meta` fields we care to preserve from the original package (priority),
  # and others we *can't* preserve (outputsToInstall).
  extractMeta = pkg: let
    meta = pkg.meta or {};
  in
    (lib.optionalAttrs (meta ? priority) { inherit (meta) priority; })
    // (lib.optionalAttrs (meta ? mainProgram) { inherit (meta) mainProgram; })
  ;

  # helper used for `wrapperType == "wrappedDerivation"` which simply symlinks all a package's binaries into a new derivation
  symlinkDirs = suffix: symlinkRoots: pkgName: package: let
    # remove altogether some problem outputs which i don't have a use for in the deployed system
    outputs = lib.remove "dev" (package.outputs or [ "out" ]);
  in (runCommand "${pkgName}-${suffix}" {
    env.symlinkRoots = lib.concatStringsSep " " symlinkRoots;
    nativeBuildInputs = [ gnused ];
    inherit outputs;
    propagatedBuildOutputs = [ ];  #< disable propagation, since we disabled the `dev` output via which things are ordinarily propagated
  } ''
    symlinkPath() {
      local inbase="$1"
      local outbase="$2"
      local path="$3"
      if [ -e "$outbase/$path" ]; then
        :  # already linked. may happen when e.g. the package has bin/foo, and sbin -> bin.
      elif [ -L "$inbase/$path" ]; then
        local target=$(readlink "$inbase/$path")
        if [[ "$target" =~ ^$inbase/ ]]; then
          # absolute link back into the same package
          nixDebugLog "handling $path: descending into absolute symlink to same package: $target"
          target=$(echo "$target" | sed 's:${package}/::')
          ln -s "$outbase/$target" "$outbase/$path"
          # create/link the backing path
          # N.B.: if some leading component of the backing path is also a symlink... this might not work as expected.
          local parent=$(dirname "$out/$target")
          mkdir -p "$parent"
          symlinkPath "$inbase" "$outbase" "$target"
        elif [[ "$target" =~ ^/nix/store/ ]]; then
          # absolute link to another package
          nixDebugLog "handling $path: symlinking absolute store path: $target"
          ln -s "$target" "$outbase/$path"
        else
          # relative link
          nixDebugLog "handling $path: descending into relative symlink: $target"
          ln -s "$target" "$outbase/$path"
          local parent=$(dirname "$path")
          local derefParent=$(dirname "$outbase/$parent/$target")
          $(set -x && mkdir -p "$derefParent")
          symlinkPath "$inbase" "$outbase" "$parent/$target"
        fi
      elif [ -d "$inbase/$path" ]; then
        nixDebugLog "handling $path: descending into directory"
        mkdir -p "$outbase/$path"
        items=($(ls -a "$inbase/$path"))
        for item in "''${items[@]}"; do
          if [ "$item" != . ] && [ "$item" != .. ] && [[ "$item" != .* ]]; then
            symlinkPath "$inbase" "$outbase" "$path/$item"
          fi
        done
      elif [ -e "$inbase/$path" ]; then
        nixDebugLog "handling $path: symlinking ordinary file"
        ln -s "$inbase/$path" "$outbase/$path"
      fi
    }

    crawlOutput() {
      local inbase="$1"
      local outbase="$2"
      mkdir -p "$outbase"
      _symlinkRoots=($symlinkRoots)
      for root in "''${_symlinkRoots[@]}"; do
        echo "crawling top-level directory for symlinking: $inbase/$root -> $outbase"
        symlinkPath "$inbase" "$outbase" "$root"
      done
    }

    ${lib.concatMapStringsSep "\n" (o:
      "crawlOutput ${package."${o}"} $" + o
    ) outputs}

    # allow downstream wrapping to hook this (and thereby actually wrap binaries, etc)
    runHook postInstall
    runHook postFixup
  '').overrideAttrs (_: {
    # specifically, preserve meta.priority
    meta = extractMeta package;
  });

  symlinkBinaries = symlinkDirs "bin-only" [ "bin" "sbin" "libexec" ];

  # helper used for `wrapperType == "wrappedDerivation"` which ensures that any copied/symlinked share/ files (like .desktop) files
  # don't point to the unwrapped binaries.
  # other important files it preserves:
  # - share/applications
  # - share/dbus-1  (frequently a source of leaked references!)
  # - share/icons
  # - share/man
  # - share/mime
  # - {etc,lib,share}/systemd
  fixHardcodedRefs = unsandboxed: sandboxedBin: unsandboxedNonBin: unsandboxedNonBin.overrideAttrs (prevAttrs: {
    postInstall = (prevAttrs.postInstall or "") + ''
      trySubstitute() {
        local _outPath="$1"
        local _pattern="$2"
        local _from=$(printf "$_pattern" "${unsandboxed}")
        local _to=$(printf "$_pattern" "${sandboxedBin}")
        printf "applying known substitutions to %s\n" "$_outPath"
        # for closure efficiency, we only want to rewrite stuff which actually needs changing,
        # and allow unchanged stuff to remain as symlinks.
        # `substitute` can't rewrite symlinks, so instead do the substitution to a temp output
        # with `--replace-fail` and only recreate the output symlink as a file if the substitution succeeds (i.e. if it matched).
        if substitute "$_outPath" ./substituteResult --replace-fail "$_from" "$_to"; then
          mv ./substituteResult "$_outPath"
        fi
      }

      # remove any files which exist in sandoxedBin (makes it possible to sandbox /opt-style packages)
      removeUnwanted() {
        local outbase="$1"
        local path="$2"
        local file_=$(basename "$path")
        if [ -f "$outbase/$path" ] || [ -L "$outbase/$path" ]; then
          for sboxBase in ${lib.concatStringsSep " " sandboxedBin.all}; do
            if [ -e "$sboxBase/$path" ]; then
              rm "$outbase/$path"
            fi
          done
        elif [ -d "$outbase/$path" ]; then
          local files=($(ls -a "$outbase/$path"))
          for item in "''${files[@]}"; do
            if [ "$item" != . ] && [ "$item" != .. ]; then
              removeUnwanted "$outbase" "$path/$item"
            fi
          done
        fi
      }

      for output in $outputs; do
        local outdir=''${!output}
        removeUnwanted "$outdir" ""

        # fixup a few files i understand well enough
        for binLoc in bin libexec sbin; do
          for d in \
            $outdir/etc/xdg/autostart/*.desktop \
            $outdir/share/applications/*.desktop \
            $outdir/share/dbus-1/{services,system-services}/*.service \
          ; do
            trySubstitute "$d" "Exec=%s/$binLoc/"
          done

          for d in $outdir/{etc,lib,share}/systemd/{system,user}/*.service; do
            for key in ExecStart ExecReload; do
              trySubstitute "$d" "$key=%s/$binLoc/"
            done
          done

          for d in $outdir/lib/udev/rules.d/*.rules; do
            # sandboxed path used as the first argument in a udev rule:
            trySubstitute "$d" '"'"%s/$binLoc"
            trySubstitute "$d" '"'"%s/etc"
            trySubstitute "$d" '"'"%s/share"
            # sandboxed path used as the n'th argument in a udev rule (e.g. RUN+="do-something /nix/store/.../etc/config")
            trySubstitute "$d" ' '"%s/$binLoc"
            trySubstitute "$d" ' '"%s/etc"
            trySubstitute "$d" ' '"%s/share"
          done

          for d in $outdir/lib/mozilla/native-messaging-hosts/*.json; do
            trySubstitute "$d" '"'"%s/$binLoc"
          done

          for d in $outdir/share/polkit-1/actions/*.policy; do
            trySubstitute "$d" '<annotate key="org.freedesktop.policykit.exec.path">'"%s/$binLoc/"
          done

          for d in $outdir/share/thumbnailers/*.thumbnailer; do
            trySubstitute "$d" "Exec=%s/$binLoc/"
            trySubstitute "$d" "TryExec=%s/$binLoc/"
          done
        done
      done
    '';
    passthru = let
      # check that sandboxedNonBin references only sandboxed binaries, and never the original unsandboxed binaries.
      # do this by dereferencing all sandboxedNonBin symlinks, and making `unsandboxed` a disallowedReference.
      sandboxedNonBin = fixHardcodedRefs unsandboxed sandboxedBin unsandboxedNonBin;
      outputs = sandboxedNonBin.outputs or [ "out" ];
      checkSandboxed = runCommand "${sandboxedNonBin.name}-check-sandboxed"
        {
          inherit outputs;
          disallowedReferences = [ unsandboxed ];
          passthru.flat = linkFarm "${sandboxedNonBin.name}-check-sandboxed-flat" (builtins.map (o: { name = o; path = checkSandboxed."${o}"; }) outputs);
        }
        # dereference every symlink, ensuring that whatever data is behind it does not reference non-sandboxed binaries.
        # the dereference *can* fail, in case it's a relative symlink that refers to a part of the non-binaries we don't patch.
        # in such case, this could lead to weird brokenness (e.g. no icons/images), so failing is reasonable.
        # N.B.: this `checkSandboxed` protects against accidentally referencing unsandboxed binaries from data files (.deskop, .service, etc).
        # there's an *additional* `checkSandboxed` further below which invokes every executable in the final package to make sure the binaries are truly sandboxed.
        (lib.concatMapStringsSep "\n" (o:
          "cp -R --dereference ${sandboxedNonBin."${o}"} $" + o
        ) sandboxedNonBin.outputs or [ "out" ])
      ;
    in (prevAttrs.passthru or {}) // { inherit checkSandboxed; };
  });

  # symlink the non-binary files from the unsandboxed package,
  # patch them to use the sandboxed binaries,
  # and add some passthru metadata to enforce no lingering references to the unsandboxed binaries.
  sandboxNonBinaries = pkgName: unsandboxed: sandboxedBin: let
    sandboxedWithoutFixedRefs = symlinkDirs "non-bin" [
      "lib/udev/rules.d"
      "lib/mozilla/native-messaging-hosts"
      "etc"
      "share"
    ] pkgName unsandboxed;
  in fixHardcodedRefs unsandboxed sandboxedBin sandboxedWithoutFixedRefs;

  # take the nearly-final sandboxed package, with binaries and all else, and
  # populate passthru attributes the caller expects, like `checkSandboxed`.
  fixupMetaAndPassthru = pkgName: pkg: extraPassthru: pkg.overrideAttrs (finalAttrs: prevAttrs: let
    nonBin = (prevAttrs.passthru or {}).sandboxedNonBin or {};
  in {
    meta = (prevAttrs.meta or {}) // {
      # take precedence over non-sandboxed versions of the same binary.
      priority = ((prevAttrs.meta or {}).priority or 0) - 1;
    };
    passthru = (prevAttrs.passthru or {}) // extraPassthru // {
      checkSandboxed = runCommand "${pkgName}-check-sandboxed" {
        preferLocalBuild = true;
        depsBuildBuild = [ bunpen ];
        nativeBuildInputs = [ file gnugrep ];
        buildInputs = builtins.map (out: finalAttrs.finalPackage."${out}") (finalAttrs.outputs or [ "out" ]);
      } ''
        # invoke each binary in a way only the sandbox wrapper will recognize,
        # ensuring that every binary has in fact been wrapped.
        _numExec=0
        _checkExecutable() {
          local dir="$1"
          local binname="$2"
          nixInfoLog "checking if $dir/$binname is sandboxed"
          nixDebugLog "  sandboxer is ${bunpen.name}"
          nixDebugLog "  PATH=$PATH"
          # XXX: call by full path because some binaries (e.g. util-linux) would otherwise
          # be shadowed by things the nix builder implicitly puts on PATH.
          # additionally, call via qemu and manually specify the interpreter *if the file has one*.
          # if the file doesn't have an interpreter, assume it's directly invokable by qemu (hence, the intentional lack of quotes around `interpreter`)
          set -x
          local realbin="$(realpath $dir/$binname)"
          echo 'echo "printing for test"' | ${stdenv.hostPlatform.emulator buildPackages} "$dir/$binname" --bunpen-drop-shell \
            | grep "printing for test"
          _numExec=$(( $_numExec + 1 ))
        }
        _checkDir() {
          local dir="$1"
          for b in $(ls "$dir"); do
            if [ -d "$dir/$b" ]; then
              if [ "$b" != .sandboxed ]; then
                _checkDir "$dir/$b"
              fi
            elif [ -x "$dir/$b" ]; then
              _checkExecutable "$dir" "$b"
            else
              test -n "$CHECK_DIR_NON_BIN"
            fi
          done
        }

        for outDir in $buildInputs; do
          nixInfoLog "starting crawl from package output: $outDir"
          # *everything* in the bin dir should be a wrapped executable
          if [ -e "$outDir/bin" ]; then
            echo "checking toplevel dir at $outDir/bin"
            _checkDir "$outDir/bin"
          fi

          # the libexec dir is 90% wrapped executables, but sometimes also .so/.la objects.
          # note that this directory isn't flat
          if [ -e "$outDir/libexec" ]; then
            echo "checking toplevel dir at $outDir/libexec"
            CHECK_DIR_NON_BIN=1 _checkDir "$outDir/libexec"
          fi
        done

        echo "successfully tested $_numExec binaries"
        test "$_numExec" -ne 0
        mkdir "$out"
        # forward prevAttrs checkSandboxed, to guarantee correctness for the /share directory (`sandboxNonBinaries`).
        ln -s ${nonBin.checkSandboxed.flat or "/dev/null"} "$out/sandboxed-non-binaries"
      '';
    };
  });

  make-sandboxed = { pkgName, package, wrapperType, embedSandboxer ? false, extraSandboxerArgs ? [], passthru ? {} }:
  let
    unsandboxed = package;
    bunpen' = if embedSandboxer then
      # optionally hard-code the sandboxer. this forces rebuilds, but allows deep iteration w/o deploys.
      lib.getExe bunpen
    else
      #v prefer to load by bin name to reduce rebuilds
      bunpen.meta.mainProgram
    ;

    # two ways i could wrap a package in a sandbox:
    # 1. package.overrideAttrs, with `postFixup`.
    # 2. pkgs.symlinkJoin, creating an entirely new package which calls into the inner binaries.
    #
    # here we switch between the options.
    # regardless of which one is chosen here, all other options are exposed via `passthru`.
    sandboxedBy = {
      inplace = sandboxBinariesInPlace
        bunpen'
        extraSandboxerArgs
        pkgName
        (makeHookable unsandboxed);

      wrappedDerivation = let
        sandboxedBin = sandboxBinariesInPlace
          bunpen'
          extraSandboxerArgs
          pkgName
          (symlinkBinaries pkgName unsandboxed);
        sandboxedNonBin = sandboxNonBinaries pkgName unsandboxed sandboxedBin;
        outputs = lib.unique (
          (sandboxedBin.outputs or [ "out" ])
          ++ (sandboxedNonBin.outputs or [ "out" ])
        );
      in runCommand "${pkgName}-sandboxed-all" {
        inherit outputs;
        preferLocalBuild = true;
        nativeBuildInputs = [ xorg.lndir ];
        passthru = { inherit sandboxedBin sandboxedNonBin unsandboxed; };
        # specifically, for priority
        meta = extractMeta sandboxedBin;
      } ''
        ${lib.concatMapStringsSep "\n" (o:
          "mkdir -p $" + o + "\n"
          + (lib.optionalString ((sandboxedBin."${o}" or null) != null) ("lndir -silent ${sandboxedBin.${o}} $" + o + "\n"))
          + (lib.optionalString ((sandboxedNonBin."${o}" or null) != null) ("lndir -silent ${sandboxedNonBin.${o}} $" + o + "\n"))
        ) outputs}
        runHook postInstall
        runHook postFixup
      '';
    };
    packageWrapped = sandboxedBy."${wrapperType}";
    packageWithMeta = fixupMetaAndPassthru pkgName packageWrapped (passthru // {
      # allow the user to build this package, but sandboxed in a different manner.
      # e.g. `<pkg>.sandboxedBy.inplace`.
      # e.g. `<pkg>.sandboxedBy.wrappedDerivation.sandboxedNonBin`
      inherit sandboxedBy;
    });
  in if package.outputSpecified or false then
    # packages like `dig` are actually aliases to `bind.dnsutils`, so preserve that
    packageWithMeta."${package.outputName}"
  else
    packageWithMeta
  ;
in make-sandboxed
