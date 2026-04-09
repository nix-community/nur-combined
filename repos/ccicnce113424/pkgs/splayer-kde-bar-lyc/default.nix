{
  sources,
  lib,
  stdenvNoCC,
  qt6,
}:
let
  metadata = lib.importJSON sources.extract."metadata.json";
in
stdenvNoCC.mkDerivation {
  inherit (sources) pname src;
  version = metadata.KPlugin.Version;

  installPhase = ''
    runHook preInstall

    outputdir=share/plasma/plasmoids/${metadata.KPlugin.Id}
    mkdir -p $out/$outputdir/contents
    cp -r contents/* $out/$outputdir/contents
    cp metadata.json $out/$outputdir/metadata.json

    runHook postInstall
  '';

  # fixupPhase = ''
  #   runHook preFixup

  #   substituteInPlace $out/$outputdir/contents/ui/main.qml \
  #     --replace-fail "import QtWebSockets" "import \"file:${qt6.qtwebsockets}/lib/qt-6/qml/QtWebSockets\""

  #   runHook postFixup
  # '';

  passthru.id = metadata.KPlugin.Id;

  meta = {
    description = "Taskbar lyrics plasmoid widget for SPlayer";
    homepage = "https://github.com/lrst6963/Splayer-kde-bar-lyc";
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    license = lib.licenses.gpl3Only;
  };
}
