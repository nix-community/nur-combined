{
  lib,
  stdenv,
  fetchFromGitHub,
  electron_39-bin,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
}:

stdenv.mkDerivation rec {
  pname = "outline-electron";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Mag1cByt3s";
    repo = "outline-electron";
    rev = version; # Use a tag or commit hash for reproducibility
    sha256 = "125m2m08pw7qimzx28hfn01maai2d17ngnpk8afysv8f7nlwjd8n"; # nix-prefetch-url --unpack https://github.com/Mag1cByt3s/outline-electron/archive/refs/tags/1.0.0.tar.gz
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "outline-electron";
      desktopName = "Outline";
      comment = "Outline desktop client";
      exec = "outline-electron";
      icon = "outline-electron";
      categories = [
        "Office"
        "Documentation"
      ];
      terminal = false;
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/outline-electron
    cp -r src/. $out/lib/outline-electron/

    mkdir -p $out/bin
    makeWrapper ${electron_39-bin}/bin/electron $out/bin/outline-electron \
      --add-flags "$out/lib/outline-electron"

    mkdir -p $out/share/icons/hicolor/192x192/apps
    cp assets/icon-192.png $out/share/icons/hicolor/192x192/apps/outline-electron.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "Electron wrapper for Outline wiki";
    homepage = "https://github.com/Mag1cByt3s/outline-electron";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "outline-electron";
  };
}
