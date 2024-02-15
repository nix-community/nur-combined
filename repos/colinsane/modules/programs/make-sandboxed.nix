{ lib
, buildPackages
, callPackage
, runCommand
, runtimeShell
, sane-sandboxed
, symlinkJoin
, writeShellScriptBin
, writeTextFile
}:
let
  fakeSaneSandboxed = writeShellScriptBin "sane-sandboxed" ''
    # behave like the real sane-sandboxed with SANE_SANDBOX_DISABLE=1,
    # but in a manner which avoids taking a dependency on the real sane-sandboxed.
    # the primary use for this is to allow a package's `check` phase to work even when sane-sandboxed isn't available.
    _origArgs=($@)

    # throw away all arguments until we find the path to the binary which is being sandboxed
    while [ "$#" -gt 0 ] && ! [[ "$1" =~ /\.sandboxed/ ]]; do
      shift
    done
    if [ "$#" -eq 0 ]; then
      >&2 echo "sane-sandbox: failed to parse args: ''${_origArgs[*]}"
      exit 1
    fi

    if [ -z "$SANE_SANDBOX_DISABLE" ]; then
      >&2 echo "sane-sandbox: not called with SANE_SANDBOX_DISABLE=1; unsure how to sandbox: ''${_origArgs[*]}"
      exit 1
    fi
    # assume that every argument after the binary name is an argument for the binary and not for the sandboxer.
    exec "$@"
  '';

  makeHookable = pkg:
    if ((pkg.override or {}).__functionArgs or {}) ? runCommand then
      pkg.override {
        runCommand = name: env: cmd: runCommand name env (cmd + lib.optionalString (name == pkg.name) ''
          # if the package is a runCommand (common for wrappers), then patch it to call our `postFixup` hook, first
          runHook postFixup
        '');
      }
    else
      # assume the package already calls postFixup (if not, we error during system-level build)
      pkg;

  # take an existing package, which may have a `bin/` folder as well as `share/` etc,
  # and patch the `bin/` items in-place
  sandboxBinariesInPlace = binMap: sane-sandboxed': extraSandboxArgsStr: pkgName: pkg: pkg.overrideAttrs (unwrapped: {
    # disable the sandbox and inject a minimal fake sandboxer which understands that flag,
    # in order to support packages which invoke sandboxed apps in their check phase.
    # note that it's not just for packages which invoke their *own* binaries in check phase,
    # but also packages which invoke OTHER PACKAGES' sandboxed binaries.
    # hence, put the fake sandbox in nativeBuildInputs instead of nativeCheckInputs.
    env = (unwrapped.env or {}) // {
      SANE_SANDBOX_DISABLE = 1;
    };
    nativeBuildInputs = (unwrapped.nativeBuildInputs or []) ++ [
      fakeSaneSandboxed
    ];
    disallowedReferences = (unwrapped.disallowedReferences or []) ++ [
      # the fake sandbox gates itself behind SANE_SANDBOX_DISABLE, so if it did end up deployed
      # then it wouldn't permit anything not already permitted. but it would still be annoying.
      fakeSaneSandboxed
    ];

    postFixup = (unwrapped.postFixup or "") + ''
      getProfileFromBinMap() {
        case "$1" in
          ${builtins.concatStringsSep "\n" (lib.mapAttrsToList
            (bin: profile: ''
              (${bin})
                echo "${profile}"
              ;;
            '')
            binMap
          )}
          (*)
            ;;
        esac
      }
      sandboxWrap() {
        _name="$1"
        _profileFromBinMap="$(getProfileFromBinMap $_name)"

        _profiles=("$_profileFromBinMap" "$_name" "${pkgName}" "${unwrapped.pname or ""}" "${unwrapped.name or ""}")
        # filter to just the unique profiles
        _profileArgs=(${extraSandboxArgsStr})
        for _profile in "''${_profiles[@]}"; do
          if [ -n "$_profile" ] && ! [[ " ''${_profileArgs[@]} " =~ " $_profile " ]]; then
            _profileArgs+=("--sane-sandbox-profile" "$_profile")
          fi
        done

        # N.B.: unlike `makeWrapper`, we place the unwrapped binary in a subdirectory and *preserve its name*.
        # the upside of this is that for applications which read "$0" to decide what to do (e.g. busybox, git)
        # they work as expected without any special hacks.
        # if desired, makeWrapper-style naming could be achieved by leveraging `exec -a <original_name>`.
        mkdir -p "$out/bin/.sandboxed"
        if [[ "$(readlink $out/bin/$_name)" =~ ^\.\./ ]]; then
          # relative links which ascend a directory (into a non-bin/ directory)
          # won't point to the right place if we naively move them
          ln -s "../$(readlink $out/bin/$_name)" "$out/bin/.sandboxed/$_name"
          rm "$out/bin/$_name"
        else
          mv "$out/bin/$_name" "$out/bin/.sandboxed/"
        fi
        cat <<EOF >> "$out/bin/$_name"
    #!${runtimeShell}
    exec ${sane-sandboxed'} \
    ''${_profileArgs[@]} \
    "$out/bin/.sandboxed/$_name" "\$@"
    EOF
        chmod +x "$out/bin/$_name"
      }

      for _p in $(ls "$out/bin/"); do
        sandboxWrap "$_p"
      done
    '';
  });

  # helper used for `wrapperType == "wrappedDerivation"` which simply symlinks all a package's binaries into a new derivation
  symlinkBinaries = pkgName: package: runCommand "${pkgName}-bin-only" {} ''
    mkdir -p "$out/bin"
    for d in $(ls "${package}/bin"); do
      ln -s "${package}/bin/$d" "$out/bin/$d"
    done
    # allow downstream wrapping to hook this (and thereby actually wrap the binaries)
    runHook postFixup
  '';

  # helper used for `wrapperType == "wrappedDerivation"` which ensures that and copied/symlinked share/ files (like .desktop) files
  # don't point to the unwrapped binaries.
  # other important files it preserves:
  # - share/applications
  # - share/dbus-1  (frequently a source of leaked references!)
  # - share/icons
  # - share/man
  # - share/mime
  fixHardcodedRefs = unsandboxed: sandboxedBin: unsandboxedNonBin: unsandboxedNonBin.overrideAttrs (prevAttrs: {
    postInstall = (prevAttrs.postInstall or "") + ''
      trySubstitute() {
        _outPath="$1"
        _pattern="$2"
        _from=$(printf "$_pattern" "${unsandboxed}")
        _to=$(printf "$_pattern" "${sandboxedBin}")
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
      for d in $out/share/applications/*.desktop; do
        trySubstitute "$d" "Exec=%s/bin/"
      done
      for d in $out/share/dbus-1/services/*.service; do
        trySubstitute "$d" "Exec=%s/bin/"
      done
    '';
    passthru = (prevAttrs.passthru or {}) // {
      # check that sandboxedNonBin references only sandboxed binaries, and never the original unsandboxed binaries.
      # do this by dereferencing all sandboxedNonBin symlinks, and making `unsandboxed` a disallowedReference.
      # further, since the sandboxed binaries intentionally reference the unsandboxed binaries,
      # we have to patch those out as a way to whitelist them.
      checkSandboxed = let
        sandboxedNonBin = fixHardcodedRefs unsandboxed "/dev/null" unsandboxedNonBin;
      in runCommand "${sandboxedNonBin.name}-check-sandboxed"
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
  sandboxNonBinaries = pkgName: unsandboxed: sandboxedBin:
    fixHardcodedRefs unsandboxed sandboxedBin (runCommand "${pkgName}-sandboxed-non-binary" {} ''
      set -e
      mkdir "$out"
      if [ -e "${unsandboxed}/share" ]; then
        mkdir "$out/share"
        ${buildPackages.xorg.lndir}/bin/lndir "${unsandboxed}/share" "$out/share"
      fi
      runHook postInstall
    '');

  # take the nearly-final sandboxed package, with binaries and and else, and
  # populate passthru attributes the caller expects, like `checkSandboxed`.
  fixupMetaAndPassthru = pkgName: pkg: extraPassthru: pkg.overrideAttrs (finalAttrs: prevAttrs: let
    final = fixupMetaAndPassthru pkgName pkg extraPassthru;
    nonBin = (prevAttrs.passthru or {}).sandboxedNonBin or {};
  in {
    meta = (prevAttrs.meta or {}) // {
      # take precedence over non-sandboxed versions of the same binary.
      priority = ((prevAttrs.meta or {}).priority or 0) - 1;
    };
    passthru = (prevAttrs.passthru or {}) // extraPassthru // {
      checkSandboxed = runCommand "${pkgName}-check-sandboxed" {} ''
        set -e
        # invoke each binary in a way only the sandbox wrapper will recognize,
        # ensuring that every binary has in fact been wrapped.
        _numExec=0
        for b in ${finalAttrs.finalPackage}/bin/*; do
          echo "checking if $b is sandboxed"
          PATH="${finalAttrs.finalPackage}/bin:${sane-sandboxed}/bin:$PATH" \
            SANE_SANDBOX_DISABLE=1 \
            "$b" --sane-sandbox-replace-cli echo "printing for test" \
            | grep "printing for test"
          _numExec=$(( $_numExec + 1 ))
        done

        echo "successfully tested $_numExec binaries"
        test "$_numExec" -ne 0
        mkdir "$out"
        # forward prevAttrs checkSandboxed, to guarantee correctness for the /share directory (`sandboxNonBinaries`).
        ln -s ${nonBin.checkSandboxed or "/dev/null"} "$out/sandboxed-non-binaries"
      '';
    };
  });

  make-sandboxed = { pkgName, package, wrapperType, binMap ? {}, embedSandboxer ? false, extraSandboxerArgs ? [], passthru ? {} }@args:
  let
    unsandboxed = package;
    sane-sandboxed' = if embedSandboxer then
      # optionally hard-code the sandboxer. this forces rebuilds, but allows deep iteration w/o deploys.
      lib.getExe sane-sandboxed
    else
      #v prefer to load by bin name to reduce rebuilds
      sane-sandboxed.meta.mainProgram
    ;

    extraSandboxerArgsStr = lib.escapeShellArgs extraSandboxerArgs;

    # two ways i could wrap a package in a sandbox:
    # 1. package.overrideAttrs, with `postFixup`.
    # 2. pkgs.symlinkJoin, creating an entirely new package which calls into the inner binaries.
    #
    # here we switch between the options.
    # regardless of which one is chosen here, all other options are exposed via `passthru`.
    sandboxedBy = {
      inplace = sandboxBinariesInPlace
        binMap
        sane-sandboxed'
        extraSandboxerArgsStr
        pkgName
        (makeHookable unsandboxed);

      wrappedDerivation = let
        sandboxedBin = sandboxBinariesInPlace
          binMap
          sane-sandboxed'
          extraSandboxerArgsStr
          pkgName
          (symlinkBinaries pkgName unsandboxed);
        sandboxedNonBin = sandboxNonBinaries pkgName unsandboxed sandboxedBin;
      in symlinkJoin {
        name = "${pkgName}-sandboxed-all";
        paths = [ sandboxedBin sandboxedNonBin ];
        passthru = { inherit sandboxedBin sandboxedNonBin unsandboxed; };
      };
    };
    packageWrapped = sandboxedBy."${wrapperType}";
  in
    fixupMetaAndPassthru pkgName packageWrapped (passthru // {
      # allow the user to build this package, but sandboxed in a different manner.
      # e.g. `<pkg>.sandboxedBy.inplace`.
      inherit sandboxedBy;
    })
  ;
in make-sandboxed
