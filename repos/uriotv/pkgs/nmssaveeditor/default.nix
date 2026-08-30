{
  lib,
  stdenvNoCC,
  fetchurl,
  jre8,
  coreutils,
  icoutils,
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

  iconSrc = fetchurl {
    url = "https://github.com/goatfungus/NMSSaveEditor/raw/6047315f47321e2a8400d38bf8d904bcca88bb8d/NMSSaveEditor.exe";
    hash = "sha256-WsKiV59AKg98ZU4XNP8euZ+RDF2woPfG6ygaqn+wymI=";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    icoutils
    makeWrapper
  ];

  installPhase = ''
    install -Dm444 ${finalAttrs.src} $out/share/${finalAttrs.pname}/NMSSaveEditor.jar

    mkdir icons
    wrestool --extract --type=14 --output=icons ${finalAttrs.iconSrc}
    icotool --extract --index=1 --output=icons icons/*.ico
    install -Dm444 icons/*_32x32x4.png \
      $out/share/icons/hicolor/32x32/apps/${finalAttrs.pname}.png
    icotool --extract --index=2 --output=icons icons/*.ico
    install -Dm444 icons/*_16x16x4.png \
      $out/share/icons/hicolor/16x16/apps/${finalAttrs.pname}.png

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
