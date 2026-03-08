{
  lib,
  fetchurl,
  stdenv,
  autoPatchelfHook,
  dpkg,
  SDL2,
  freetype,
  openal,
  libGLU,
}:

stdenv.mkDerivation {
  pname = "osmos-demo";
  version = "0-unstable-2023-06-21";

  src = fetchurl {
    urls = [
      "https://www.hemispheregames.com/latest_osmos_demo_linux_deb"
      "https://web.archive.org/web/20230621223503id_*/http://www.hemispheregames.com:80/latest_osmos_demo_linux_deb"
    ];
    hash = "sha256-Fd8L4EI43OY8p1+SzLmij5rtDFHBvhZchZ/PeQgaJ5c=";
  };

  sourceRoot = ".";
  unpackCmd = "dpkg-deb -x $src .";

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    SDL2
    libGLU
    freetype
    openal
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out bin
    ln -fs ../../opt/OsmosDemo/OsmosDemo usr/games/OsmosDemo
    ln -s ../usr/games/OsmosDemo bin/OsmosDemo
    mv opt usr bin $out/

    runHook postInstall
  '';

  meta = {
    description = "Osmos game (DEMO)";
    homepage = "https://www.osmos-game.com/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ nagy ];
    platforms = lib.platforms.linux;
    mainProgram = "OsmosDemo";
  };
}
