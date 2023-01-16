{ lib
, buildNpmPackage
, fetchFromGitHub
, makeBinaryWrapper
, makeDesktopItem
, copyDesktopItems
, electron
, python3
, xorg }:

buildNpmPackage rec {
  pname = "freelook";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "eNkru";
    repo = "freelook";
    rev = "main";
    hash = "sha256-kpXp//ni9qJll9TVH/uaJUGUyh8YmDeUHceazSoCfJ8=";
  };

  npmDepsHash = "sha256-guT7LsGJqBWSn2MVKFcElHHdVIuHw8VW7m3BgBlgFEI=";
  dontNpmBuild = true;

  nativeBuildInputs = [
    copyDesktopItems
    makeBinaryWrapper
    python3
  ];

  buildInputs = [
    xorg.libX11
    xorg.libxkbfile
  ];

  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/electron-outlook
    cp -ra src/* $out/lib/electron-outlook
    cp -ra node_modules $out/lib/electron-outlook

    for icon in 16x16 32x32 48x48 64x64 128x128 256x256 512x512; do
      install -Dm644 build/icons/$icon.png $out/share/icons/hicolor/$icon/apps/freelook.png
    done

    makeWrapper '${electron}/bin/electron' $out/bin/freelook \
      --inherit-argv0 \
      --add-flags $out/lib/electron-outlook/main.js

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "freelook";
      exec = "freelook";
      icon = "freelook";
      desktopName = "Freelook";
      comment = meta.description;
      categories = [ "Office" ];
      startupWMClass = "Freelook";
    })
  ];

  meta = with lib; {
    description = "Unofficial desktop client for Microsoft Outlook";
    homepage = "https://github.com/eNkru/freelook";
    license = licenses.mit;
    maintainers = with maintainers; [ tboerger ];
    platforms = platforms.linux;
  };
}
