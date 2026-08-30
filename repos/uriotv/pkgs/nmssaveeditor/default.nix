{
  lib,
  stdenvNoCC,
  fetchurl,
  jre8,
  coreutils,
  jdk8,
  makeDesktopItem,
  makeWrapper,
}:

let
  desktopItem = makeDesktopItem {
    name = "nmssaveeditor";
    desktopName = "No Man's Sky Save Editor";
    genericName = "Save editor";
    comment = "Save editor for No Man's Sky";
    exec = "nmssaveeditor";
    categories = [ "Game" ];
    icon = "nmssaveeditor";
    keywords = [
      "No Man's Sky"
      "NMS"
      "save"
      "editor"
    ];
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "nmssaveeditor";
  version = "1.21.0";

  src = fetchurl {
    url = "https://github.com/goatfungus/NMSSaveEditor/raw/6047315f47321e2a8400d38bf8d904bcca88bb8d/NMSSaveEditor.jar";
    hash = "sha256-74mK9OHEwMJabGUp3+pSUgzaJDODVE2NNYrRCq46F4w=";
  };

  nativeBuildInputs = [
    jdk8
    makeWrapper
  ];

  unpackPhase = ''
    runHook preUnpack
    jar xf ${finalAttrs.src} nomanssave/icons/UI-FILEICON.PNG
    runHook postUnpack
  '';

  installPhase = ''
    install -Dm444 ${finalAttrs.src} $out/share/${finalAttrs.pname}/NMSSaveEditor.jar

    install -Dm444 nomanssave/icons/UI-FILEICON.PNG \
      $out/share/icons/hicolor/32x32/apps/${finalAttrs.pname}.png

    install -Dm444 ${desktopItem}/share/applications/${finalAttrs.pname}.desktop \
      $out/share/applications/${finalAttrs.pname}.desktop
    makeWrapper ${jre8}/bin/java $out/bin/${finalAttrs.pname} \
      --run 'data_dir="''${XDG_DATA_HOME:-''${HOME:?HOME must be set}/.local/share}/${finalAttrs.pname}"; ${coreutils}/bin/mkdir -p "$data_dir"; ${coreutils}/bin/cp -f ${finalAttrs.src} "$data_dir/NMSSaveEditor.jar"' \
      --add-flags '-jar "$data_dir/NMSSaveEditor.jar"'
  '';

  meta = with lib; {
    description = "Save editor for No Man's Sky";
    homepage = "https://github.com/goatfungus/NMSSaveEditor";
    license = licenses.unfree;
    platforms = platforms.linux;
    mainProgram = "nmssaveeditor";
    sourceProvenance = [ sourceTypes.binaryBytecode ];
  };
})
