{ lib
, stdenv
, fetchurl
, makeWrapper
, temurin-jre-bin-25
, libGL
, libX11
, libXext
, libXrandr
, libXtst
, libXi
, freetype
, glib
, alsa-lib
, copyDesktopItems
, makeDesktopItem
}:

let
  icon = fetchurl {
    url = "https://raw.githubusercontent.com/themuhamed/mcicons/refs/heads/main/public/icons/minecraft_grass_block.png";
    hash = "sha256-MgUJks6ExC9uiOHFvOuWSsosatdPeHMomG3ON72wW4c=";
  };
in
stdenv.mkDerivation rec {
  pname = "olauncher";
  version = "1.7.3_04";

  src = fetchurl {
    url = "https://github.com/olauncher/olauncher/releases/download/v${version}/olauncher-${version}-redist.jar";
    hash = "sha256-K3CFG1h9E/EKO0b6mxdHuixO05CjyNXLr90udcDKjL8=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper copyDesktopItems ];

  runtimeLibs = lib.makeLibraryPath [
    libGL
    libX11
    libXext
    libXrandr
    libXtst
    libXi
    freetype
    glib
    alsa-lib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm444 "$src" "$out/share/java/olauncher.jar"

    makeWrapper ${temurin-jre-bin-25}/bin/java $out/bin/olauncher \
      --add-flags "-jar $out/share/java/olauncher.jar" \
      --prefix LD_LIBRARY_PATH : "$runtimeLibs"

    install -Dm444 ${icon} $out/share/icons/hicolor/256x256/apps/olauncher.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "olauncher";
      exec = "olauncher";
      icon = "olauncher";
      desktopName = "OLauncher";
      genericName = "Minecraft Launcher";
      comment = "A modified version of the old Minecraft Launcher";
      categories = [ "Game" ];
    })
  ];

  meta = with lib; {
    description = "Modified old-style Minecraft launcher with Microsoft authentication support";
    homepage = "https://github.com/olauncher/olauncher";
    changelog = "https://github.com/olauncher/olauncher/releases/tag/v${version}";
    license = licenses.cc0;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    platforms = platforms.linux;
    mainProgram = "olauncher";
  };
}
