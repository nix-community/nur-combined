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
  glib,
  gtk3,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

rustPlatform.buildRustPackage (
  finalAttrs:
  {
    pname = "futo-notes";
    version = "1.9.4";

    strictDeps = true;

    src = fetchFromGitLab {
      domain = "gitlab.futo.org";
      owner = "futo-notes";
      repo = "futo-notes";
      tag = "v${finalAttrs.version}";
      hash = "sha256-U4tp4zrgdtJ8WHmry4KqxyE31RJxaufi3fmfeog80J8=";
    };

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pnpm_10;
      fetcherVersion = 4;
      hash = "sha256-8iTy9/nhurKXXsz9y6QiL9yQINniJaBhzfaJBisfKl0=";
    };

    cargoHash = "sha256-LO690k1AESP7DfGyxWebop9WTSmqhQvvCmyyquqIc3s=";

    # The Cargo workspace root is in the repo root; we build the tauri app.
    buildAndTestSubdir = "apps/tauri/src-tauri";

    nativeBuildInputs = [
      pkg-config
      cargo-tauri.hook
      nodejs_22
      pnpmConfigHook
      pnpm_10
      makeWrapper
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
      # rustc is built for 14.0; tauri.conf.json otherwise forces 11.0.
      MACOSX_DEPLOYMENT_TARGET = "14.0";
    };

    doCheck = false;

    postInstall = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
      ln -s futo-notes-tauri $out/bin/futo-notes
    '';

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
