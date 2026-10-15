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
  makeWrapper,
  glib,
  gtk3,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "futo-notes";
  version = "1.9.0";

  strictDeps = true;

  src = fetchFromGitLab {
    domain = "gitlab.futo.org";
    owner = "futo-notes";
    repo = "futo-notes";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pMTtOihbZKh2589fG4ybT5jUoz2NhUSAgMeP0J4vTpo=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 4;
    hash = "sha256-ZU6NR0kmp4Vjid4S+MCzUuHR6qxbYOHXlFOS71itkpU=";
  };

  cargoHash = "sha256-bXLbmwRxS8DU2AfBASrgFpUxs7cTJQ6tkCcfvaHpXlw=";

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
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    glib
    gtk3
    webkitgtk_4_1
  ];

  # cargo-tauri.hook always passes --bundles; Darwin only accepts app/dmg/ios.
  # Skip the Apple bundler (codesign --options) and install the binary ourselves.
  dontTauriBuild = lib.optionalString stdenv.hostPlatform.isDarwin "1";
  dontTauriInstall = lib.optionalString stdenv.hostPlatform.isDarwin "1";

  buildPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    runHook preBuild
    export CARGO_TARGET_DIR="$PWD/target"
    printf '\nbuild.target-dir = "%s"\n' "$CARGO_TARGET_DIR" >> config.toml
    pushd ${finalAttrs.buildAndTestSubdir}
    cargo tauri build --no-bundle --target ${stdenv.hostPlatform.rust.rustcTarget} -- \
      -j "$NIX_BUILD_CORES" --target ${stdenv.hostPlatform.rust.rustcTarget} --offline --profile "''${cargoBuildType:-release}"
    popd
    runHook postBuild
  '';

  env = {
    CI = "true";
    # rustc is built for 14.0; tauri.conf.json otherwise forces 11.0.
    MACOSX_DEPLOYMENT_TARGET = "14.0";
  };

  doCheck = false;

  installPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    runHook preInstall

    bin="target/${stdenv.hostPlatform.rust.cargoShortTarget}/''${cargoBuildType:-release}/futo-notes-tauri"
    app="$out/Applications/FUTO Notes.app"
    mkdir -p "$app/Contents/MacOS" "$out/bin"
    cp "$bin" "$app/Contents/MacOS/FUTO Notes"

    cat > "$app/Contents/Info.plist" <<EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleExecutable</key>
      <string>FUTO Notes</string>
      <key>CFBundleIdentifier</key>
      <string>com.futo.notes</string>
      <key>CFBundleName</key>
      <string>FUTO Notes</string>
      <key>CFBundlePackageType</key>
      <string>APPL</string>
      <key>CFBundleShortVersionString</key>
      <string>${finalAttrs.version}</string>
      <key>LSMinimumSystemVersion</key>
      <string>14.0</string>
      <key>NSHighResolutionCapable</key>
      <true/>
    </dict>
    </plist>
    EOF

    makeWrapper "$app/Contents/MacOS/FUTO Notes" "$out/bin/futo-notes"

    runHook postInstall
  '';

  postInstall = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    ln -s futo-notes-tauri $out/bin/futo-notes
  '';

  meta = {
    description = "Voice-first, private note taking application";
    homepage = "https://gitlab.futo.org/futo-notes/futo-notes";
    license = lib.licenses.unfree;
    mainProgram = "futo-notes";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
