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

  desktopItems = [
    (makeDesktopItem {
      name = "gemini-desktop";
      exec = "gemini-desktop %U";
      icon = "gemini-desktop";
      desktopName = "Gemini Desktop";
      comment = "A desktop wrapper for Google Gemini with enhanced features";
      categories = [ "Utility" ];
    })
  ];

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

    install -Dm644 ${
      if useNewIcon then newIcon else "build/icon.png"
    } $out/share/icons/hicolor/256x256/apps/gemini-desktop.png

    cp ${if useNewIcon then newIcon else "build/icon.png"} $out/share/gemini-desktop/icon.png

    makeBinaryWrapper ${lib.getExe electron} $out/bin/gemini-desktop \
      --add-flags $out/share/gemini-desktop/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --inherit-argv0

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
