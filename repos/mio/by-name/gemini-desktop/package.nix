{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  fetchurl,
  asar,
  makeBinaryWrapper,
  makeDesktopItem,
  copyDesktopItems,
  desktopToDarwinBundle,
  electron,
  useNewIcon ? true,
}:

let
  newIcon = fetchurl {
    url = "https://web.archive.org/web/20260607211200if_/https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Google_Gemini_icon_2025.svg/250px-Google_Gemini_icon_2025.svg.png";
    hash = "sha256-Jwd/thLtaGdcUuT7G+dfQrGFbht9MaZOm/7tyMBvJ40=";
  };
in
buildNpmPackage rec {
  pname = "gemini-desktop";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "bwendell";
    repo = "gemini-desktop";
    rev = "v${version}";
    hash = "sha256-/JY6ylqf2jvsDAZjnZRmV1/nlA28YlVGzD24xdgSMs8=";
  };

  patches = [
    ./disable-updates.patch
    ./disable-hotkey-notice.patch
  ];

  postPatch = lib.optionalString useNewIcon ''
    cp ${newIcon} build/icon.png
    cp ${newIcon} public/icon.png
    cp ${newIcon} src/renderer/assets/icon.png
  '';

  npmDepsHash = "sha256-dOgkqID35J6wznqgb86AE7RzPRgRfDxFFFUoLvNXakw=";

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  nativeBuildInputs = [
    asar
    makeBinaryWrapper
    copyDesktopItems
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle;

  desktopItems = lib.optional (!stdenv.hostPlatform.isDarwin) (makeDesktopItem {
    name = "gemini-desktop";
    exec = "gemini-desktop %U";
    icon = "gemini-desktop";
    desktopName = "Gemini Desktop";
    comment = "A desktop wrapper for Google Gemini with enhanced features";
    categories = [ "Utility" ];
  });

  buildPhase = ''
    runHook preBuild

    npm run build
    npm run build:electron

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    npm prune --omit=dev --no-save

    # Remove unused native binaries for other platforms to save space
    find node_modules/@node-llama-cpp -mindepth 1 -maxdepth 1 ! -name "linux-x64*" -exec rm -rf {} +

    mkdir -p $out/share/gemini-desktop
    asar pack . $out/share/gemini-desktop/app.asar

    mkdir -p $out/share/icons/hicolor/256x256/apps
    ${
      if stdenv.hostPlatform.isDarwin then
        ''
          magick convert ${
            if useNewIcon then newIcon else "build/icon.png"
          } -resize 256x256 $out/share/icons/hicolor/256x256/apps/gemini-desktop.png
        ''
      else
        ''
          install -m644 ${
            if useNewIcon then newIcon else "build/icon.png"
          } $out/share/icons/hicolor/256x256/apps/gemini-desktop.png
        ''
    }

    cp ${if useNewIcon then newIcon else "build/icon.png"} $out/share/gemini-desktop/icon.png

    ${
      if stdenv.hostPlatform.isDarwin then
        ''
          # Build a proper, self-contained macOS app bundle
          mkdir -p "$out/Applications/Gemini Desktop.app/Contents/MacOS"
          mkdir -p "$out/Applications/Gemini Desktop.app/Contents/Resources"

          # Copy binary and plist from Electron.app
          cp "${electron}/Applications/Electron.app/Contents/MacOS/Electron" \
            "$out/Applications/Gemini Desktop.app/Contents/MacOS/Gemini Desktop"
          cp "${electron}/Applications/Electron.app/Contents/Info.plist" \
            "$out/Applications/Gemini Desktop.app/Contents/Info.plist"

          # Symlink Frameworks to save space
          ln -s "${electron}/Applications/Electron.app/Contents/Frameworks" \
            "$out/Applications/Gemini Desktop.app/Contents/Frameworks"

          # Place resources
          cp $out/share/gemini-desktop/app.asar \
            "$out/Applications/Gemini Desktop.app/Contents/Resources/app.asar"

          # Compile the icon
          mkdir -p tmpicons
          magick convert $out/share/icons/hicolor/256x256/apps/gemini-desktop.png -resize 16x16 tmpicons/16x16.png
          magick convert $out/share/icons/hicolor/256x256/apps/gemini-desktop.png -resize 32x32 tmpicons/32x32.png
          magick convert $out/share/icons/hicolor/256x256/apps/gemini-desktop.png -resize 128x128 tmpicons/128x128.png
          magick convert $out/share/icons/hicolor/256x256/apps/gemini-desktop.png -resize 256x256 tmpicons/256x256.png
          magick convert $out/share/icons/hicolor/256x256/apps/gemini-desktop.png -resize 512x512 tmpicons/512x512.png
          icnsutil convert tmpicons/16x16.argb tmpicons/16x16.png
          icnsutil convert tmpicons/32x32.argb tmpicons/32x32.png
          rm tmpicons/16x16.png tmpicons/32x32.png
          icnsutil compose --toc "$out/Applications/Gemini Desktop.app/Contents/Resources/gemini-desktop.icns" tmpicons/*

          # Update Info.plist
          chmod +w "$out/Applications/Gemini Desktop.app/Contents/Info.plist"
          substituteInPlace "$out/Applications/Gemini Desktop.app/Contents/Info.plist" \
            --replace-fail "<string>Electron</string>" "<string>Gemini Desktop</string>" \
            --replace-fail "<string>com.github.Electron</string>" "<string>org.nixos.gemini-desktop</string>" \
            --replace-fail "<string>electron.icns</string>" "<string>gemini-desktop.icns</string>"

          # Create a binary wrapper or symlink in bin/
          mkdir -p $out/bin
          makeBinaryWrapper "$out/Applications/Gemini Desktop.app/Contents/MacOS/Gemini Desktop" "$out/bin/gemini-desktop"
        ''
      else
        ''
          makeBinaryWrapper ${lib.getExe electron} $out/bin/gemini-desktop \
            --add-flags $out/share/gemini-desktop/app.asar \
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
            --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
            --inherit-argv0
        ''
    }

    runHook postInstall
  '';

  meta = {
    description = "A desktop wrapper for Google Gemini with enhanced features";
    homepage = "https://github.com/bwendell/gemini-desktop";
    license = lib.licenses.mit;
    mainProgram = "gemini-desktop";
    platforms = lib.platforms.all;
  };
}
