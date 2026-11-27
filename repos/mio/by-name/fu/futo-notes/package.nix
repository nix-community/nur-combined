{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchPnpmDeps,
  pnpmConfigHook,
  rustPlatform,
  cargo-tauri,
  nodejs_22,
  pnpm_10,
  pkg-config,
  openssl,
  zstd,
  makeWrapper,
  git,
  nix,
  writeShellApplication,
  nix-update,
  python3,
  cacert,
  glib,
  gtk3,
  webkitgtk_4_1,
  wrapGAppsHook3,
  wasm-bindgen-cli_0_2_129,
  lld,
}:

rustPlatform.buildRustPackage (
  finalAttrs:
  {
    pname = "futo-notes";
    version = "2.0.1";

    strictDeps = true;

    src = fetchFromGitLab {
      domain = "gitlab.futo.org";
      owner = "futo-notes";
      repo = "futo-notes";
      tag = "v${finalAttrs.version}";
      hash = "sha256-K8zxKo6KM8xVr7caJg1uoyh3RU5TRco6BHQfWb19oUY=";
    };

    # Nix's rustc already ships the wasm32 standard library; skip upstream's
    # rustup check and use the exact wasm-bindgen CLI version from Cargo.lock.
    patches = [ ./editor-wasm-no-rustup.patch ];

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pnpm_10;
      fetcherVersion = 4;
      hash = "sha256-9rp1yjiEH9BOAChjT+5EnEvALRC+FPxkTFB1ysxP6vw=";
    };

    cargoHash = "sha256-XoeMa2naAEXbEb8ZOSisdlUBFYRQQbdSeEGH4kM/BlQ=";

    # The Cargo workspace root is in the repo root; we build the tauri app.
    buildAndTestSubdir = "apps/tauri/src-tauri";

    nativeBuildInputs = [
      pkg-config
      cargo-tauri.hook
      lld
      nodejs_22
      pnpmConfigHook
      pnpm_10
      makeWrapper
      wasm-bindgen-cli_0_2_129
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      wrapGAppsHook3
    ];

    buildInputs = [
      openssl
      # tantivy (new in 1.9.3) pulls in zstd-sys, which links the system libzstd
      # found through pkg-config rather than compiling the vendored one.
      zstd
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      glib
      gtk3
      webkitgtk_4_1
    ];

    env = {
      CI = "true";
      WASM_BINDGEN = lib.getExe wasm-bindgen-cli_0_2_129;
      # rustc is built for 14.0; tauri.conf.json otherwise forces 11.0.
      MACOSX_DEPLOYMENT_TARGET = "14.0";
    };

    doCheck = false;

    postInstall = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
      ln -s futo-notes-tauri $out/bin/futo-notes
    '';

    passthru.updateScript = writeShellApplication {
      name = "update-futo-notes";
      runtimeInputs = [
        cacert
        git
        nix
        nix-update
        python3
      ];
      text = ''
        export UPDATE_NIX_ATTR_PATH="futo-notes"
        export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
        exec python3 ${./update.py} "$@"
      '';
    };

    meta = {
      description = "Voice-first, private note taking application";
      homepage = "https://gitlab.futo.org/futo-notes/futo-notes";
      changelog = "https://gitlab.futo.org/futo-notes/futo-notes/-/releases/v${finalAttrs.version}";
      license = lib.licenses.unfree;
      mainProgram = "futo-notes";
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
    };
  }
  // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # cargo-tauri.hook always passes --bundles, and the Apple bundler needs
    # codesign plus an SDK the Nix sandbox does not expose. Build the app binary
    # without bundling and assemble the bundle here instead.
    dontTauriBuild = "1";
    dontTauriInstall = "1";

    buildPhase = ''
      runHook preBuild

      export CARGO_TARGET_DIR="$PWD/target"
      printf '\nbuild.target-dir = "%s"\n' "$CARGO_TARGET_DIR" >> config.toml

      pushd ${finalAttrs.buildAndTestSubdir}
      cargo tauri build --no-bundle \
        --target ${stdenv.hostPlatform.rust.rustcTarget} \
        -- -j "$NIX_BUILD_CORES" \
        --target ${stdenv.hostPlatform.rust.rustcTarget} \
        --offline \
        --profile "''${cargoBuildType:-release}"
      popd

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      bin="target/${stdenv.hostPlatform.rust.cargoShortTarget}/''${cargoBuildType:-release}/futo-notes-tauri"
      app="$out/Applications/FUTO Notes.app"
      mkdir -p "$app/Contents/MacOS" "$out/bin"
      cp "$bin" "$app/Contents/MacOS/FUTO Notes"

      # Finder metadata for the bundle; generated so the version string is
      # escaped rather than spliced into hand-written XML.
      cat > "$app/Contents/Info.plist" <<'EOF'
      ${lib.generators.toPlist { escape = true; } {
        CFBundleExecutable = "FUTO Notes";
        CFBundleIdentifier = "com.futo.notes";
        CFBundleName = "FUTO Notes";
        CFBundlePackageType = "APPL";
        CFBundleShortVersionString = finalAttrs.version;
        CFBundleVersion = finalAttrs.version;
        LSMinimumSystemVersion = "14.0";
        NSHighResolutionCapable = true;
      }}
      EOF

      makeWrapper "$app/Contents/MacOS/FUTO Notes" "$out/bin/futo-notes"

      runHook postInstall
    '';
  }
)
