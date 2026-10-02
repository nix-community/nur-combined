{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nibble-gui";
  version = "0.1.0-unstable-2026-10-02";

  src = fetchFromGitHub {
    owner = "lillycham";
    repo = "nibble";
    rev = "c50e3c00a9c3b05ea2671d6d7acb8dd281d36fd0";
    hash = "sha256-YX5JjBvDEYHJOyTuoKYL74SxqYd6jZ+DGnbOHgE7B/o=";
  };

  # The window is its own Cargo project inside the nibble repository.
  sourceRoot = "${finalAttrs.src.name}/gui";

  cargoHash = "sha256-STJB9CKAHtxkdqSwYAdpaORUccwUO2HPK7Ukd0BBFIM=";

  # An app bundle around the binary, so it has a place in the Dock and
  # Spotlight can find it. bin/nibble-gui stays, as a link into it.
  postInstall = ''
    app=$out/Applications/nibble.app/Contents
    mkdir -p $app/MacOS
    mv $out/bin/nibble-gui $app/MacOS/nibble-gui
    ln -s $app/MacOS/nibble-gui $out/bin/nibble-gui
    cat > $app/Info.plist <<EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleName</key><string>nibble</string>
      <key>CFBundleDisplayName</key><string>nibble</string>
      <key>CFBundleIdentifier</key><string>com.lillycham.nibble</string>
      <key>CFBundleExecutable</key><string>nibble-gui</string>
      <key>CFBundlePackageType</key><string>APPL</string>
      <key>CFBundleShortVersionString</key><string>0.1.0</string>
      <key>CFBundleVersion</key><string>0.1.0</string>
      <key>LSMinimumSystemVersion</key><string>13.0</string>
      <key>NSHighResolutionCapable</key><true/>
    </dict>
    </plist>
    EOF
  '';

  meta = {
    description = "A native chat window for nibble";
    homepage = "https://github.com/lillycham/nibble";
    # One file is adapted from GPUI's Apache-2.0 example.
    license = with lib.licenses; [ mit asl20 ];
    # GPUI on Linux needs the Wayland and X11 libraries wired in, which
    # nobody has tried here.
    platforms = lib.platforms.darwin;
    mainProgram = "nibble-gui";
  };
})
