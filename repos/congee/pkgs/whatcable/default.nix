{
  lib,
  swiftPackages,
  fetchFromGitHub,
  sqlite,
}:

swiftPackages.stdenv.mkDerivation rec {
  pname = "whatcable";
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "darrylmorley";
    repo = "whatcable";
    rev = "v${version}";
    hash = "sha256-1L6TyyFRVO1+iZAJETq6AHEZlTCrF4mXJojSdm1nfJQ=";
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
    mkdir -p "$appDir/Contents/MacOS" "$appDir/Contents/Helpers" "$out/bin"

    cp "$binPath/WhatCable" "$appDir/Contents/MacOS/WhatCable"
    cp "$binPath/whatcable-cli" "$appDir/Contents/Helpers/whatcable"

    # SwiftPM-generated resource accessors look next to Bundle.main.bundleURL.
    # Put resources beside the .app for GUI launches and beside the helper for
    # the CLI symlink resolved through Contents/Helpers/whatcable.
    cp -R "$binPath"/WhatCable_*.bundle "$appDir"/
    cp -R "$binPath"/WhatCable_*.bundle "$appDir/Contents/Helpers"/

    cat > "$appDir/Contents/Info.plist" <<PLIST
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleDevelopmentRegion</key><string>en</string>
      <key>CFBundleExecutable</key><string>WhatCable</string>
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
