{
  sources,
  lib,
  stdenvNoCC,
  lyrica,
  qt6,
}:
let
  metadata = builtins.fromJSON sources."plasmoid/metadata.json";
in
stdenvNoCC.mkDerivation {
  inherit (sources) pname src;
  version = metadata.KPlugin.Version;

  installPhase = ''
    runHook preInstall

    outputdir=share/plasma/plasmoids/${metadata.KPlugin.Id}
    mkdir -p $out/$outputdir
    cp -r plasmoid/* $out/$outputdir

    substituteInPlace $out/$outputdir/contents/ui/main.qml \
      --replace-fail "\$HOME/.local/$outputdir/contents/bin/lyrica" "${lib.getExe lyrica}" \
      --replace-fail "import QtWebSockets" "import \"file:${qt6.qtwebsockets}/lib/qt-6/qml/QtWebSockets\""

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    description = "KDE Plasma lyrics widget focused on simplicity and integration";
    homepage = "https://github.com/chiyuki0325/lyrica";
    changelog = "https://github.com/chiyuki0325/lyrica/releases/tag/${sources.version}";
    license = lib.licenses.mit;
  };
}
