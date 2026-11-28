{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  sdl3,
  zlib,
  desktopToDarwinBundle,
  nix-update-script,
  writeShellApplication,
}:

let
  version = "0.9.1";

  # cmake/Dependencies.cmake fetches libchdr from git at configure time; the
  # sandbox has no network, so it gets this pinned source tree instead.
  libchdr = fetchFromGitHub {
    owner = "rtissera";
    repo = "libchdr";
    tag = "v0.3.0";
    hash = "sha256-jBk3Kd4q3HO3i2SxS0mBpQ80Vfm8vj1PQMXouK6Y/+k=";
  };
in
stdenv.mkDerivation {
  pname = "gt3-revisited";
  inherit version;

  src = fetchFromGitHub {
    owner = "matt-pulsipher";
    repo = "GT3-revisited";
    tag = "v${version}";
    hash = "sha256-0nbw4XMwwaWKCCb2IlRZHVPZfhhEeGzJ3ryALlZBPBk=";
  };

  patches = [
    ./0001-use-desktop-to-darwin-bundle.patch
    ./0002-disable-automatic-update-dialog.patch
  ];

  nativeBuildInputs = [
    cmake
    ninja
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ desktopToDarwinBundle ];

  buildInputs = [
    sdl3
    zlib
  ];

  cmakeFlags = [
    "-DGT3R_BUILD_TESTS=OFF"
    "-DGT3R_BUILD_TOOLS=OFF"
    # desktopToDarwinBundle creates the .app from the installed desktop entry
    # and icon, avoiding upstream's sips/iconutil/codesign bundle phase.
    "-DGT3R_DARWIN_BUNDLE=OFF"
    "-DFETCHCONTENT_SOURCE_DIR_LIBCHDR=${libchdr}"
  ];

  # The game reads the disc image at run time; nothing from it is built in.
  installPhase = ''
    runHook preInstall
    cmake --install . --prefix $out
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    plist="$out/Applications/GT3 Revisited.app/Contents/Info.plist"
    cat > "$plist" <<EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleDevelopmentRegion</key>
      <string>en</string>
      <key>CFBundleExecutable</key>
      <string>GT3 Revisited</string>
      <key>CFBundleIconFile</key>
      <string>gt3r.icns</string>
      <key>CFBundleIdentifier</key>
      <string>org.gt3revisited.gt3r</string>
      <key>CFBundleInfoDictionaryVersion</key>
      <string>6.0</string>
      <key>CFBundleName</key>
      <string>GT3 Revisited</string>
      <key>CFBundleDisplayName</key>
      <string>GT3 Revisited</string>
      <key>CFBundlePackageType</key>
      <string>APPL</string>
      <key>CFBundleShortVersionString</key>
      <string>${version}</string>
      <key>CFBundleVersion</key>
      <string>${version}</string>
      <key>LSApplicationCategoryType</key>
      <string>public.app-category.racing-games</string>
      <key>LSMinimumSystemVersion</key>
      <string>12.0</string>
      <key>NSHighResolutionCapable</key>
      <true/>
      <key>GCSupportsControllerUserInteraction</key>
      <true/>
      <key>CFBundleDocumentTypes</key>
      <array>
        <dict>
          <key>CFBundleTypeName</key>
          <string>PS2 disc image</string>
          <key>CFBundleTypeRole</key>
          <string>Viewer</string>
          <key>LSHandlerRank</key>
          <string>Alternate</string>
          <key>CFBundleTypeExtensions</key>
          <array>
            <string>iso</string>
            <string>chd</string>
          </array>
        </dict>
      </array>
    </dict>
    </plist>
    EOF
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-gt3-revisited-unwrapped";
    text = ''
      export UPDATE_NIX_ATTR_PATH="gt3-revisited-unwrapped"
      exec ${
        lib.escapeShellArgs (nix-update-script {
          extraArgs = [
            "--version-regex"
            "v(.*)"
          ];
        })
      } "$@"
    '';
  };

  meta = {
    description = "Open reimplementation of the Gran Turismo 3 A-Spec engine (needs your own disc)";
    longDescription = ''
      GT3 Revisited reimplements the Gran Turismo 3 A-Spec engine for modern
      platforms. It contains no game data: the disc image you made from your
      own copy is read at run time (`gt3r /path/to/image.iso`).
    '';
    homepage = "https://github.com/matt-pulsipher/GT3-revisited";
    license = lib.licenses.mit;
    mainProgram = "gt3r";
    # Upstream's macOS package is Apple silicon; Windows and mobile are built
    # by its own release scripts.
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
