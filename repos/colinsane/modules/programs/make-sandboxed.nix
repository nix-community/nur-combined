{ lib
, buildPackages
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
  fixHardcodedRefs = unsandboxed: sandboxedNonBin: sandboxedBin: sandboxedNonBin.overrideAttrs (prevAttrs: {
    postInstall = (prevAttrs.postInstall or "") + ''
      trySubstitute() {
        _outPath="$1"
        _pattern="$2"
        _from=$(printf "$_pattern" "${unsandboxed}")
        _to=$(printf "$_pattern" "${sandboxedBin}")
        printf "applying known substitutions to %s" "$_outPath"
        # substituteInPlace can fail on symlinks, but frequently that's fine because
        # the referenced file is already safe, so don't error on failure here.
        substituteInPlace "$_outPath" \
          --replace "$_from" "$_to" \
          || true
      }
      # fixup a few files i understand well enough
      for d in $out/share/applications/*.desktop; do
        trySubstitute "$d" "Exec=%s/bin/"
      done
      for d in $out/share/dbus-1/services/*.service; do
        trySubstitute "$d" "Exec=%s/bin/"
      done
    '';
  });

  # copy or symlink the non-binary files from the unsandboxed package,
  # patch them to use the sandboxed binaries,
  # and add some passthru metadata to enforce no lingering references to the unsandboxed binaries.
  sandboxNonBinaries = method: pkgName: unsandboxed: sandboxedBin: let
    unsandboxedNonBinaries = runCommand "${pkgName}-sandboxed-non-binary" {
      passthru.checkSandboxed = (copyNonBinaries pkgName unsandboxed sandboxedBin).overrideAttrs (_: {
        # copy everything, patch just as we would for any method, and then enforce no refs to the unsandboxed pkg.
        # we can do that only because we're copying instead of symlinking.
        # TODO: instead of `passthru.checkSandboxed`, just make this a build prereq of the out derivation,
        #       such that it fails the main derivation if it would contain bad refs
        disallowedReferences = [ unsandboxed ];
      });
    } ''
      mkdir "$out"
      if [ -e "${unsandboxed}/share" ]; then
        ${method} "${unsandboxed}/share" "$out/"
      fi
      runHook postInstall
      '';
    in fixHardcodedRefs unsandboxed unsandboxedNonBinaries sandboxedBin;

  copyNonBinaries = sandboxNonBinaries "cp -R";
  symlinkNonBinaries = sandboxNonBinaries "${buildPackages.xorg.lndir}/bin/lndir";

  # take the nearly-final sandboxed package, with binaries and and else, and
  # populate passthru attributes the caller expects, like `sandboxProfiles` and `checkSandboxed`.
  fixupMetaAndPassthru = pkgName: pkg: sandboxProfiles: extraPassthru: pkg.overrideAttrs (finalAttrs: prevAttrs: let
    final = fixupMetaAndPassthru pkgName pkg sandboxProfiles extraPassthru;
  in {
    meta = (prevAttrs.meta or {}) // {
      # take precedence over non-sandboxed versions of the same binary.
      priority = ((prevAttrs.meta or {}).priority or 0) - 1;
    };
    passthru = (prevAttrs.passthru or {}) // extraPassthru // {
      inherit sandboxProfiles;
      checkSandboxed = runCommand "${pkgName}-check-sandboxed" {} ''
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
        # forward prevAttrs checkSandboxed, to guarantee correctness for the /share directory (`sandboxNonBinaries`).
        ${lib.optionalString (prevAttrs ? passthru && prevAttrs.passthru ? checkSandboxed)
          ''echo "also checked: ${prevAttrs.passthru.checkSandboxed}"''
        }
        test "$_numExec" -ne 0 && touch "$out"
      '';
    };
  });

  make-sandboxed = { pkgName, package, method, wrapperType, vpn ? null, allowedHomePaths ? [], allowedRootPaths ? [], autodetectCliPaths ? null, binMap ? {}, capabilities ? [], embedProfile ? false, embedSandboxer ? false, extraConfig ? [], whitelistPwd ? false }@args:
  let
    sane-sandboxed' = if embedSandboxer then
      # optionally hard-code the sandboxer. this forces rebuilds, but allows deep iteration w/o deploys.
      lib.getExe sane-sandboxed
    else
      #v prefer to load by bin name to reduce rebuilds
      sane-sandboxed.meta.mainProgram
    ;

    allowPath = p: [
      "--sane-sandbox-path"
      p
    ];
    allowHomePath = p: [
      "--sane-sandbox-home-path"
      p
    ];
    allowPaths = paths: lib.flatten (builtins.map allowPath paths);
    allowHomePaths = paths: lib.flatten (builtins.map allowHomePath paths);

    capabilityFlags = lib.flatten (builtins.map (c: [ "--sane-sandbox-cap" c ]) capabilities);

    vpnItems = [
      "--sane-sandbox-net"
      vpn.bridgeDevice
    ] ++ lib.flatten (builtins.map (addr: [
      "--sane-sandbox-dns"
      addr
    ]) vpn.dns);

    sandboxFlags = [
      "--sane-sandbox-method" method
    ] ++ allowPaths allowedRootPaths
      ++ allowHomePaths allowedHomePaths
      ++ capabilityFlags
      ++ lib.optionals (autodetectCliPaths != null) [ "--sane-sandbox-autodetect" autodetectCliPaths ]
      ++ lib.optionals whitelistPwd [ "--sane-sandbox-add-pwd" ]
      ++ lib.optionals (vpn != null) vpnItems
      ++ extraConfig;

    sandboxProfilesPkg = writeTextFile {
      name = "${pkgName}-sandbox-profiles";
      destination = "/share/sane-sandboxed/profiles/${pkgName}.profile";
      text = builtins.concatStringsSep "\n" sandboxFlags;
    };
    sandboxProfileDir = "${sandboxProfilesPkg}/share/sane-sandboxed/profiles";

    maybeEmbedProfilesDir = lib.optionalString embedProfile ''"--sane-sandbox-profile-dir" "${sandboxProfileDir}"'';

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
        maybeEmbedProfilesDir
        pkgName
        (makeHookable package);

      wrappedDerivation = let
        binaries = sandboxBinariesInPlace
          binMap
          sane-sandboxed'
          maybeEmbedProfilesDir
          pkgName
          (symlinkBinaries pkgName package);
        nonBinaries = symlinkNonBinaries pkgName package binaries;
      in symlinkJoin {
        name = "${pkgName}-sandboxed-all";
        paths = [ binaries nonBinaries ];
        passthru = { inherit binaries nonBinaries; };
      };
    };
    packageWrapped = sandboxedBy."${wrapperType}";
  in
    fixupMetaAndPassthru pkgName packageWrapped sandboxProfilesPkg {
      inherit sandboxedBy;
      withEmbeddedSandboxer = make-sandboxed (args // { embedSandboxer = true; embedProfile = true; });
    }
  ;
in make-sandboxed
