{
  sources,

  lib,
  stdenv,

  copyDesktopItems,
  electron,
  glib,
  libGL,
  makeDesktopItem,
  makeWrapper,
}:
stdenv.mkDerivation {
  inherit (sources.chainner-bin) pname version src;

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/{bin,libexec,share/icons/hicolor/256x256/apps}
    cp -r * $out/libexec

    makeWrapper ${lib.getExe electron} $out/bin/chainner \
      --add-flags $out/libexec/resources/app \
      --set LD_LIBRARY_PATH ${
        lib.makeLibraryPath [
          libGL
          glib
        ]
      }

    rm $out/libexec/portable

    ln -s $out/libexec/resources/app/.vite/renderer/main_window/256x256.png $out/share/icons/hicolor/256x256/apps/chainner.png

    runHook postBuild
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "chainner";
      desktopName = "chaiNNer";
      comment = "A flowchart-based image processing GUI";
      genericName = "Image Processing GUI";
      exec = "chainner %U";
      icon = "chainner";
      categories = [ "Graphics" ];
      mimeTypes = [ "application/json" ];
    })
  ];

  meta = {
    description = "A node-based image processing GUI aimed at making chaining image processing tasks easy and customizable.";
    homepage = "https://chainner.app/";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    mainProgram = "chainner";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
