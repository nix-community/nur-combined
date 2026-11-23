{
  lib,
  stdenv,
  mullvad-vpn,
  mullvad,
  cargo,
  rustc,
  makeWrapper,
}:

# nixpkgs' mullvad-vpn packages only the Linux desktop target and marks Darwin
# badPlatforms. Upstream does ship a macOS target (`pack:mac`), so this variant
# builds the GUI bundle on Darwin as well. The non-Darwin attributes are left
# untouched.
mullvad-vpn.overrideAttrs (
  old:
  {
    pname = "mullvad-vpn_patched";
  }
  // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    npmBuildScript = "pack:mac";

    # No keychain/certificates in the build sandbox: produce an unsigned app.
    env = (old.env or { }) // {
      CSC_IDENTITY_AUTO_DISCOVERY = "false";
    };

    patches = (old.patches or [ ]) ++ [ ./darwin-build.patch ];

    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      cargo
      rustc
      makeWrapper
    ];

    postPatch = (old.postPatch or "") + ''
      # The packager deletes the unpacked .app after building; keep it for
      # the install phase.
      sed -i 's|await fs.promises.rm(dir, { recursive: true });|// keep unpacked app|' \
        packages/mullvad-vpn/tasks/distribution.cjs

      # distribution.cjs copies the daemon binaries out of
      # dist-assets/${stdenv.hostPlatform.parsed.cpu.name}-apple-darwin.
      target=${stdenv.hostPlatform.parsed.cpu.name}-apple-darwin
      mkdir -p ../dist-assets/$target
      for bin in mullvad mullvad-daemon mullvad-problem-report mullvad-setup; do
        ln -sf ${mullvad}/bin/$bin ../dist-assets/$target/$bin
      done

      # nseventforwarder is a Rust workspace member; build it from the
      # daemon's vendored crates (including its git dependencies) instead of
      # re-vendoring the same lockfile.
      cd ..
      mkdir -p .cargo
      sed "s|@vendor@|${mullvad.cargoDeps}|g" \
        ${mullvad.cargoDeps}/.cargo/config.toml >> .cargo/config.toml
      export CARGO_NET_OFFLINE=true
      cd desktop
    '';

    # electron-builder copies the Electron runtime and then rewrites its
    # plists; the store's copy is read-only, so give it a writable one.
    preBuild = ''
      electron_root=$(dirname "$(node -p "require('electron')")")
      mkdir -p electron-dist
      cp -R "$electron_root/Electron.app" electron-dist/
      chmod -R u+w electron-dist
      # nixpkgs points electronDist at the read-only store copy.
      sed -i "s|^    electronDist: .*|    electronDist: '$PWD/electron-dist',|" \
        packages/mullvad-vpn/tasks/distribution.cjs

      # npm's script sandboxing skips the workspace packages' postinstall
      # type generation, which the GUI's type-check depends on.
      npm -w nseventforwarder run build-typescript
      npm -w windows-utils run build-typescript
    '';

    installPhase = ''
      runHook preInstall

      app=$(find ../dist -maxdepth 3 -type d -name 'Mullvad VPN.app' -print -quit)
      if [ -z "$app" ]; then
        echo "mullvad-vpn: no Mullvad VPN.app in the electron-builder output" >&2
        find ../dist -maxdepth 3 -print >&2
        exit 1
      fi

      mkdir -p "$out/Applications" "$out/bin"
      cp -R "$app" "$out/Applications/Mullvad VPN.app"
      makeWrapper "$out/Applications/Mullvad VPN.app/Contents/MacOS/Mullvad VPN" "$out/bin/mullvad-vpn"

      runHook postInstall
    '';

    # The GUI's checks assume the Linux packaging; verify the bundle instead.
    doCheck = false;
    dontVersionCheck = true;
    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      test -x "$out/Applications/Mullvad VPN.app/Contents/MacOS/Mullvad VPN"
      test -x "$out/bin/mullvad-vpn"
      runHook postInstallCheck
    '';

    meta = (old.meta or { }) // {
      badPlatforms = [ ];
      platforms = lib.platforms.darwin ++ lib.platforms.linux;
    };
  }
)
