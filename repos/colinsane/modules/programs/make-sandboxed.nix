{ lib
, runCommand
, runtimeShell
, sane-sandboxed
, writeShellScriptBin
, writeTextFile
}:
let
  fakeSaneSandboxed = writeShellScriptBin "sane-sandboxed" ''
    # behave like the real sane-sandboxed with SANE_SANDBOX_DISABLE=1,
    # but in a manner which avoids taking a dependency on the real sane-sandboxed.
    # the primary use for this is to allow a package's `check` phase to work even when sane-sandboxed isn't available.
    _origArgs=($@)
    while [ "$#" -gt 0 ] && ! [[ "$1" =~ \.[^/]*-sandboxed$ ]]; do
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
    exec "$@"
  '';
  # helper used for `wrapperType == "wrappedDerivation"` which simply symlinks all a package's binaries into a new derivation
  symlinkBinaries = pkgName: package: runCommand "${pkgName}-sandboxed" {} ''
    mkdir -p "$out/bin"
    for d in $(ls "${package}/bin"); do
      ln -s "${package}/bin/$d" "$out/bin/$d"
    done
    # postFixup can do the actual wrapping
    runHook postFixup
  '';
in
{ pkgName, package, method, wrapperType, vpn ? null, allowedHomePaths ? [], allowedRootPaths ? [], autodetectCliPaths ? false, binMap ? {}, capabilities ? [], extraConfig ? [], embedProfile ? false, whitelistPwd ? false }:
let
  sane-sandboxed' = sane-sandboxed.meta.mainProgram;  #< load by bin name to reduce rebuilds

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
    ++ lib.optionals autodetectCliPaths [ "--sane-sandbox-autodetect" ]
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
  # note that no.2 ("wrappedDerivation") *doesn't support .desktop files yet*.
  # the final package simply doesn't include .desktop files, only bin/.
  package' = if wrapperType == "inplace" then
    if ((package.override or {}).__functionArgs or {}) ? runCommand then
      package.override {
        runCommand = name: env: cmd: runCommand name env (cmd + lib.optionalString (name == package.name) ''
          # if the package is a runCommand (common for wrappers), then patch it to call our `postFixup` hook, first
          runHook postFixup
        '');
      }
    else
      package
  else if wrapperType == "wrappedDerivation" then
    symlinkBinaries pkgName package
  else
    builtins.throw "unknown wrapperType: ${wrapperType}";

  packageWrapped = package'.overrideAttrs (unwrapped: {
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
        _profileArgs=(${maybeEmbedProfilesDir})
        for _profile in "''${_profiles[@]}"; do
          if [ -n "$_profile" ] && ! [[ " ''${_profileArgs[@]} " =~ " $_profile " ]]; then
            _profileArgs+=("--sane-sandbox-profile" "$_profile")
          fi
        done

        mv "$out/bin/$_name" "$out/bin/.$_name-sandboxed"
        cat <<EOF >> "$out/bin/$_name"
    #!${runtimeShell}
    exec ${sane-sandboxed'} \
    ''${_profileArgs[@]} \
    "$out/bin/.$_name-sandboxed" "\$@"
    EOF
        chmod +x "$out/bin/$_name"
      }

      for _p in $(ls "$out/bin/"); do
        sandboxWrap "$_p"
      done
    '';

    meta = (unwrapped.meta or {}) // {
      # take precedence over non-sandboxed versions of the same binary.
      priority = ((unwrapped.meta or {}).priority or 0) - 1;
    };

    passthru = (unwrapped.passthru or {}) // {
      checkSandboxed = runCommand "${pkgName}-check-sandboxed" {} ''
        # invoke each binary in a way only the sandbox wrapper will recognize,
        # ensuring that every binary has in fact been wrapped.
        _numExec=0
        for b in ${packageWrapped}/bin/*; do
          echo "checking if $b is sandboxed"
          PATH="${packageWrapped}/bin:${sane-sandboxed}/bin:$PATH" \
            SANE_SANDBOX_DISABLE=1 \
            "$b" --sane-sandbox-replace-cli echo "printing for test" \
            | grep "printing for test"
          _numExec=$(( $_numExec + 1 ))
        done

        echo "successfully tested $_numExec binaries"
        test "$_numExec" -ne 0 && touch "$out"
      '';

      sandboxProfiles = sandboxProfilesPkg;
    };
  });
in
  packageWrapped
