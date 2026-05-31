{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  electron,
}:

buildNpmPackage rec {
  pname = "gemini-desktop";
  version = "0.11.2";

  src = fetchFromGitHub {
    owner = "bwendell";
    repo = "gemini-desktop";
    rev = "v${version}";
    hash = "sha256-m2kPb3rEAtgN4zpNrilVUjBWGhVLgc8bXW8eAxsDcXU=";
  };

  npmDepsHash = "sha256-CZ6ThtIRfJix1F/LcgGd37nxNJBmmmQuyCcuSODvh8E=";

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

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

    mkdir -p $out/lib/gemini-desktop
    cp -r dist dist-electron package.json $out/lib/gemini-desktop/

    install -Dm644 build/icon.png $out/share/pixmaps/gemini-desktop.png

    makeWrapper ${lib.getExe electron} $out/bin/gemini-desktop \
      --add-flags $out/lib/gemini-desktop/dist-electron/main/main.cjs \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"

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
