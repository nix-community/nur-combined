{
  lib,
  swiftPackages,
  fetchFromGitHub,
  sqlite,
}:

swiftPackages.stdenv.mkDerivation rec {
  pname = "whatcable";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "darrylmorley";
    repo = "whatcable";
    rev = "v${version}";
    hash = "sha256-zeQ1pQXyD5zIiSFnWOkBsn2+w83g3yX267EgbOABtsw=";
  };

  nativeBuildInputs = with swiftPackages; [
    swift
    swiftpm
  ];

  buildInputs = [
    sqlite
  ];

  postPatch = ''
    mkdir -p Sources/CSQLite
    cat > Sources/CSQLite/module.modulemap <<EOF
    module CSQLite [system] {
      header "${sqlite.dev}/include/sqlite3.h"
      link "sqlite3"
      export *
    }
EOF

    substituteInPlace Sources/WhatCableCore/Cable/CableDB.swift \
      --replace-fail 'import SQLite3' 'import CSQLite'

    # Swift 5.10 in nixpkgs treats these weak-self captures as errors in
    # concurrently-executing closures; keep the source-equivalent shape that
    # upstream/fork workarounds use for stricter concurrency checking.
    substituteInPlace Sources/WhatCable/Services/UpdateChecker.swift \
      --replace-fail \
        '        timer = Timer.scheduledTimer(withTimeInterval: Self.pollInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.check(silent: true) }
        }' \
        '        timer = Timer.scheduledTimer(withTimeInterval: Self.pollInterval, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in self.check(silent: true) }
        }' \
      --replace-fail \
        '        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            Task { @MainActor in
                guard let self else { return }' \
        '        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self else { return }
            Task { @MainActor in'

    # The SwiftUI Settings scene is only present so the app can install menu
    # commands, but macOS can still open/restore that scene. If it stays as
    # EmptyView the user gets a blank "WhatCable Settings" window.
    substituteInPlace Sources/WhatCable/App/App.swift \
      --replace-fail \
        '        Settings { EmptyView() }' \
        '        Settings { SettingsView().environmentObject(AppDelegate.refreshSignal) }' \
      --replace-fail \
        '        wattsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.updateMenuBarWatts() }
        }' \
        '        wattsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in self.updateMenuBarWatts() }
        }'

    substituteInPlace Package.swift \
      --replace-fail \
        'name: "WhatCableCore",
            path: "Sources/WhatCableCore",' \
        'name: "WhatCableCore",
            dependencies: ["CSQLite"],
            path: "Sources/WhatCableCore",'

    substituteInPlace Package.swift \
      --replace-fail \
        '        .testTarget(
            name: "WhatCableCoreTests",' \
        '        .systemLibrary(
            name: "CSQLite",
            path: "Sources/CSQLite"
        ),
        .testTarget(
            name: "WhatCableCoreTests",'
  '';

  configurePhase = ''
    runHook preConfigure
    export HOME="$TMPDIR"
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    export HOME="$TMPDIR"
    swift build -c release --disable-sandbox
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    export HOME="$TMPDIR"
    binPath=$(swift build -c release --disable-sandbox --show-bin-path)

    appDir="$out/Applications/WhatCable.app"
    mkdir -p "$appDir/Contents/MacOS" "$appDir/Contents/Helpers" "$appDir/Contents/Resources" "$out/bin"

    cp "$binPath/WhatCable" "$appDir/Contents/MacOS/WhatCable"
    cp "$binPath/whatcable-cli" "$appDir/Contents/Helpers/whatcable"

    # Match upstream's .app layout: SwiftPM-generated Bundle.module accessors
    # first look under Bundle.main.resourceURL, which is Contents/Resources for
    # both the GUI binary and the helper CLI when launched from inside the app.
    cp -R "$binPath"/WhatCable_*.bundle "$appDir/Contents/Resources"/

    # Nixpkgs' SwiftPM resource accessor still probes Bundle.main.bundleURL
    # directly. Keep compatibility copies beside the app bundle and helper
    # executable so GUI and in-bundle CLI launches can find .module resources.
    cp -R "$binPath"/WhatCable_*.bundle "$appDir"/
    cp -R "$binPath"/WhatCable_*.bundle "$appDir/Contents/Helpers"/

    # macOS uses root-level .lproj markers to identify supported localizations;
    # the actual strings remain inside the SwiftPM resource bundles.
    for lproj in Sources/WhatCable/Resources/*.lproj; do
      test -d "$lproj" || continue
      mkdir -p "$appDir/Contents/Resources/$(basename "$lproj")"
    done

    if test -f scripts/AppIcon.icns; then
      cp scripts/AppIcon.icns "$appDir/Contents/Resources/AppIcon.icns"
    fi

    cat > "$appDir/Contents/Info.plist" <<PLIST
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleDevelopmentRegion</key><string>en</string>
      <key>CFBundleLocalizations</key>
      <array>
        <string>en</string>
        <string>de</string>
        <string>es</string>
        <string>fr</string>
        <string>hi</string>
        <string>hy</string>
        <string>it</string>
        <string>ja</string>
        <string>ko</string>
        <string>lv</string>
        <string>nb</string>
        <string>nl</string>
        <string>pl</string>
        <string>pt-BR</string>
        <string>ru</string>
        <string>tr</string>
        <string>uk</string>
        <string>zh-Hans</string>
        <string>zh-Hant</string>
      </array>
      <key>CFBundleExecutable</key><string>WhatCable</string>
      <key>CFBundleIconFile</key><string>AppIcon</string>
      <key>CFBundleIdentifier</key><string>uk.whatcable.whatcable</string>
      <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
      <key>CFBundleName</key><string>WhatCable</string>
      <key>CFBundleDisplayName</key><string>WhatCable</string>
      <key>CFBundlePackageType</key><string>APPL</string>
      <key>CFBundleShortVersionString</key><string>${version}</string>
      <key>CFBundleVersion</key><string>${version}</string>
      <key>LSMinimumSystemVersion</key><string>14.0</string>
      <key>LSUIElement</key><true/>
      <key>NSHighResolutionCapable</key><true/>
    </dict>
    </plist>
PLIST

    printf 'APPL????' > "$appDir/Contents/PkgInfo"

    ln -s "../Applications/WhatCable.app/Contents/Helpers/whatcable" "$out/bin/whatcable"
    cp -R "$binPath"/WhatCable_WhatCableCore.bundle "$out/bin"/

    if command -v codesign >/dev/null; then
      codesign --force --deep --sign - "$appDir" || true
    fi

    runHook postInstall
  '';

  doCheck = false;

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    export HOME="$TMPDIR"
    test -x "$out/Applications/WhatCable.app/Contents/MacOS/WhatCable"
    test -x "$out/Applications/WhatCable.app/Contents/Helpers/whatcable"
    "$out/bin/whatcable" --version | grep -F "${version}"
    "$out/bin/whatcable" --json >/dev/null
    runHook postInstallCheck
  '';

  meta = {
    description = "macOS menu bar app that explains what USB-C cables connected to a Mac can do";
    homepage = "https://github.com/darrylmorley/whatcable";
    changelog = "https://github.com/darrylmorley/whatcable/releases/tag/v${version}";
    # Upstream's top-level LICENSE says MIT is the default for this public tree.
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ congee ];
    mainProgram = "whatcable";
    platforms = [ "aarch64-darwin" ];
  };
}
