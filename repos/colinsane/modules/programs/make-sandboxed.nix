{
  lib,
  stdenv,
  buildPackages,
  file,
  gnugrep,
  makeBinaryWrapper,
  runCommandLocal,
  runtimeShell,
  sanebox,
  symlinkJoin,
  writeShellScriptBin,
  writeTextFile,
}:
let
  fakeSaneSandboxed = writeShellScriptBin "sanebox" ''
    # behave like the real sanebox with SANEBOX_DISABLE=1,
    # but in a manner which avoids taking a dependency on the real sanebox.
    # the primary use for this is to allow a package's `check` phase to work even when sanebox isn't available.
    _origArgs=($@)

    # throw away all arguments until we find the path to the binary which is being sandboxed
    while [ "$#" -gt 0 ] && ! [[ "$1" =~ /\.sandboxed/ ]]; do
      shift
    done
    if [ "$#" -eq 0 ]; then
      >&2 echo "sanebox (mock): failed to parse args: ''${_origArgs[*]}"
      exit 1
    fi

    if [ -z "$SANEBOX_DISABLE" ]; then
      >&2 echo "sanebox (mock): not called with SANEBOX_DISABLE=1; unsure how to sandbox: ''${_origArgs[*]}"
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
  sandboxBinariesInPlace = sanebox': extraSandboxArgs: pkgName: pkg: pkg.overrideAttrs (unwrapped: {
    # disable the sandbox and inject a minimal fake sandboxer which understands that flag,
    # in order to support packages which invoke sandboxed apps in their check phase.
    # note that it's not just for packages which invoke their *own* binaries in check phase,
    # but also packages which invoke OTHER PACKAGES' sandboxed binaries.
    # hence, put the fake sandbox in nativeBuildInputs instead of nativeCheckInputs.
    env = (unwrapped.env or {}) // {
      SANEBOX_DISABLE = 1;
    };
    # TODO: handle multi-output packages; until then, squash lib into the main output, particularly for `libexec`.
    # (this line here only affects `inplace` style wrapping)
    outputs = lib.remove "lib" (unwrapped.outputs or [ "out" ]);
    nativeBuildInputs = [
      # the ordering here is specific: inject our deps BEFORE the unwrapped program's
      # so that the unwrapped's take precendence and we limit interference (e.g. makeWrapper impl)
      fakeSaneSandboxed
      makeBinaryWrapper
    ] ++ (unwrapped.nativeBuildInputs or []);
    disallowedReferences = (unwrapped.disallowedReferences or []) ++ [
      # the fake sandbox gates itself behind SANEBOX_DISABLE, so if it did end up deployed
      # then it wouldn't permit anything not already permitted. but it would still be annoying.
      fakeSaneSandboxed
    ];

    postFixup = (unwrapped.postFixup or "") + ''
      assertExecutable() {
        # my programs refer to sanebox by name, not path, which triggers an over-eager assertion in nixpkgs (so, mask that)
        :
      }
      makeDocumentedCWrapper() {
        # this is identical to nixpkgs' implementation, only replace execv with execvp, the latter which looks for the executable on PATH.
        local src docs
        src=$(makeCWrapper "$@")
        src="''${src/return execv(/return execvp(}"
        docs=$(docstring "$@")
        printf '%s\n\n' "$src"
        printf '%s\n' "$docs"
      }

      sandboxWrap() {
        local _dir="$1"
        local _name="$2"

        # N.B.: unlike stock `wrapProgram`, we place the unwrapped binary in a subdirectory and *preserve its name*.
        # the upside of this is that for applications which read "$0" to decide what to do (e.g. busybox, git)
        # they work as expected without any special hacks.
        # if desired, makeWrapper-style naming could be achieved by leveraging `exec -a <original_name>`
        # or `make-wrapper --inherit-argv0`
        mkdir -p "$_dir/.sandboxed"
        if [[ "$(readlink $_dir/$_name)" =~ ^\.\./ ]]; then
          # relative links which ascend a directory (into a non-bin/ directory)
          # won't point to the right place if we naively move them
          ln -s "../$(readlink $_dir/$_name)" "$_dir/.sandboxed/$_name"
          rm "$_dir/$_name"
        else
          mv "$_dir/$_name" "$_dir/.sandboxed/"
        fi
        makeBinaryWrapper ${sanebox'} "$_dir/$_name" --suffix PATH : /run/current-system/sw/libexec/sanebox ${lib.escapeShellArgs (lib.flatten (builtins.map (f: [ "--add-flags" f ]) extraSandboxArgs))} --add-flags "$_dir/.sandboxed/$_name"
      }

      crawlAndWrap() {
        local _dir="$1"
        for _p in $(ls "$_dir/"); do
          if [ -x "$_dir/$_p" ] && ! [ -d "$_dir/$_p" ]; then
            sandboxWrap "$_dir" "$_p"
          elif [ -d "$_dir/$_p" ]; then
            crawlAndWrap "$_dir/$_p"
          fi
          # ignore all non-binaries
        done
      }

      for output in $outputs; do
        local outdir=''${!output}
        echo "scanning output '$output' at $outdir for binaries to sandbox"
        if [ -e "$outdir/bin" ]; then
          crawlAndWrap "$outdir/bin"
        fi
        if [ -e "$outdir/libexec" ]; then
          crawlAndWrap "$outdir/libexec"
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
  symlinkBinaries = pkgName: package: (runCommandLocal "${pkgName}-bin-only" {} ''
    set -e
    if [ -e "${package}/bin" ]; then
      mkdir -p "$out/bin"
      ${buildPackages.xorg.lndir}/bin/lndir "${package}/bin" "$out/bin"
    fi
    if [ "$(readlink ${package}/sbin)" == "bin" ]; then
      # weird packages like wpa_supplicant depend on a sbin/ -> bin symlink in their service files
      ln -s bin "$out/sbin"
    fi
    if [ -e "${package}/libexec" ]; then
      mkdir -p "$out/libexec"
      ${buildPackages.xorg.lndir}/bin/lndir "${package}/libexec" "$out/libexec"
    fi
    # allow downstream wrapping to hook this (and thereby actually wrap the binaries)
    runHook postFixup
  '').overrideAttrs (_: {
    # specifically, preserve meta.priority
    meta = extractMeta package;
  });

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
      # fixup a few files i understand well enough
      for d in \
        $out/etc/xdg/autostart/*.desktop \
        $out/share/applications/*.desktop \
        $out/share/dbus-1/{services,system-services}/*.service \
        $out/{etc,lib,share}/systemd/{system,user}/*.service \
      ; do
        # Exec: dbus and desktop files
        # ExecStart,ExecReload: systemd service files
        for key in Exec ExecStart ExecReload; do
          for binLoc in bin libexec sbin; do
            trySubstitute "$d" "$key=%s/$binLoc/"
          done
        done
      done
    '';
    passthru = (prevAttrs.passthru or {}) // {
      # check that sandboxedNonBin references only sandboxed binaries, and never the original unsandboxed binaries.
      # do this by dereferencing all sandboxedNonBin symlinks, and making `unsandboxed` a disallowedReference.
      # further, since the sandboxed binaries intentionally reference the unsandboxed binaries,
      # we have to patch those out as a way to whitelist them.
      checkSandboxed = let
        sandboxedNonBin = fixHardcodedRefs unsandboxed "/dev/null" unsandboxedNonBin;
      in runCommandLocal "${sandboxedNonBin.name}-check-sandboxed"
        { disallowedReferences = [ unsandboxed ]; }
        ''
          # dereference every symlink, ensuring that whatever data is behind it does not reference non-sandboxed binaries.
          # the dereference *can* fail, in case it's a relative symlink that refers to a part of the non-binaries we don't patch.
          # in such case, this could lead to weird brokenness (e.g. no icons/images), so failing is reasonable.
          cp -R --dereference "${sandboxedNonBin}" "$out"  # IF YOUR BUILD FAILS HERE, TRY SANDBOXING WITH "inplace"
        ''
      ;
    };
  });

  # symlink the non-binary files from the unsandboxed package,
  # patch them to use the sandboxed binaries,
  # and add some passthru metadata to enforce no lingering references to the unsandboxed binaries.
  sandboxNonBinaries = pkgName: unsandboxed: sandboxedBin: let
    sandboxedWithoutFixedRefs = (runCommandLocal "${pkgName}-sandboxed-non-binary" {} ''
      set -e
      mkdir "$out"
      # link in a limited subset of the directories.
      # lib/ is the primary one to avoid, because of shared objects that would be unsandboxed if dlopen'd.
      # all other directories are safe-ish, because they won't end up on PATH or LDPATH.
      for dir in etc share; do
        if [ -e "${unsandboxed}/$dir" ]; then
          mkdir "$out/$dir"
          ${buildPackages.xorg.lndir}/bin/lndir "${unsandboxed}/$dir" "$out/$dir"
        fi
      done
      runHook postInstall
    '').overrideAttrs (_: {
      # specifically for meta.priority, though it shouldn't actually matter here.
      meta = extractMeta unsandboxed;
    });
  in fixHardcodedRefs unsandboxed sandboxedBin sandboxedWithoutFixedRefs;

  # take the nearly-final sandboxed package, with binaries and and else, and
  # populate passthru attributes the caller expects, like `checkSandboxed`.
  fixupMetaAndPassthru = pkgName: pkg: extraPassthru: pkg.overrideAttrs (finalAttrs: prevAttrs: let
    nonBin = (prevAttrs.passthru or {}).sandboxedNonBin or {};
  in {
    meta = (prevAttrs.meta or {}) // {
      # take precedence over non-sandboxed versions of the same binary.
      priority = ((prevAttrs.meta or {}).priority or 0) - 1;
    };
    passthru = (prevAttrs.passthru or {}) // extraPassthru // {
      checkSandboxed = runCommandLocal "${pkgName}-check-sandboxed" {
        nativeBuildInputs = [ file gnugrep sanebox ];
        buildInputs = builtins.map (out: finalAttrs.finalPackage."${out}") (finalAttrs.outputs or [ "out" ]);
      } ''
        set -e
        # invoke each binary in a way only the sandbox wrapper will recognize,
        # ensuring that every binary has in fact been wrapped.
        _numExec=0
        _checkExecutable() {
          local dir="$1"
          local binname="$2"
          echo "checking if $dir/$binname is sandboxed"
          # XXX: call by full path because some binaries (e.g. util-linux) would otherwise
          # be shadowed by things the nix builder implicitly puts on PATH.
          # additionally, call via qemu and manually specify the interpreter *if the file has one*.
          # if the file doesn't have an interpreter, assume it's directly invokable by qemu (hence, the intentional lack of quotes around `interpreter`)
          set -x
          local realbin="$(realpath $dir/$binname)"
          local interpreter=$(file "$realbin" | grep --only-matching "a /nix/.* script" | cut -d" " -f2 || echo "")
          ${stdenv.hostPlatform.emulator buildPackages} $interpreter "$dir/$binname" --sanebox-net-dev all --sanebox-dns default --sanebox-net-gateway default --sanebox-replace-cli echo "printing for test" \
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
          echo "starting crawl from package output: $outDir"
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
        ln -s ${nonBin.checkSandboxed or "/dev/null"} "$out/sandboxed-non-binaries"
      '';
    };
  });

  make-sandboxed = { pkgName, package, wrapperType, embedSandboxer ? false, extraSandboxerArgs ? [], passthru ? {} }@args:
  let
    unsandboxed = package;
    sanebox' = if embedSandboxer then
      # optionally hard-code the sandboxer. this forces rebuilds, but allows deep iteration w/o deploys.
      lib.getExe sanebox
    else
      #v prefer to load by bin name to reduce rebuilds
      sanebox.meta.mainProgram
    ;

    # two ways i could wrap a package in a sandbox:
    # 1. package.overrideAttrs, with `postFixup`.
    # 2. pkgs.symlinkJoin, creating an entirely new package which calls into the inner binaries.
    #
    # here we switch between the options.
    # regardless of which one is chosen here, all other options are exposed via `passthru`.
    sandboxedBy = {
      inplace = sandboxBinariesInPlace
        sanebox'
        extraSandboxerArgs
        pkgName
        (makeHookable unsandboxed);

      wrappedDerivation = let
        sandboxedBin = sandboxBinariesInPlace
          sanebox'
          extraSandboxerArgs
          pkgName
          (symlinkBinaries pkgName unsandboxed);
        sandboxedNonBin = sandboxNonBinaries pkgName unsandboxed sandboxedBin;
      in symlinkJoin {
        name = "${pkgName}-sandboxed-all";
        paths = [ sandboxedBin sandboxedNonBin ];
        passthru = { inherit sandboxedBin sandboxedNonBin unsandboxed; };
        # specifically, for priority
        meta = extractMeta sandboxedBin;
      };
    };
    packageWrapped = sandboxedBy."${wrapperType}";
  in
    fixupMetaAndPassthru pkgName packageWrapped (passthru // {
      # allow the user to build this package, but sandboxed in a different manner.
      # e.g. `<pkg>.sandboxedBy.inplace`.
      # e.g. `<pkg>.sandboxedBy.wrappedDerivation.sandboxedNonBin`
      inherit sandboxedBy;
    })
  ;
in make-sandboxed
