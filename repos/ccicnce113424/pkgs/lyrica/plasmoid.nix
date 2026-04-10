{
  sources,
  lib,
  stdenvNoCC,
  lyrica,
  jq,
  qt6,
}:
let
  metadata = lib.importJSON lyrica.metadata;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = sources.pname + "-plasmoid";
  inherit (sources) src;
  inherit (lyrica) version;

  nativeBuildInputs = [ jq ];

  strictDeps = true;
  __structuredAttrs = true;

  installPhase = ''
    runHook preInstall

    outputdir=share/plasma/plasmoids/${metadata.KPlugin.Id}
    mkdir -p $out/$outputdir/contents
    cp -r frontend/kde/contents/* $out/$outputdir/contents

    jq '.KPlugin.Version = "${finalAttrs.version}"' \
      frontend/kde/metadata.json > $out/$outputdir/metadata.json

    runHook postInstall
  '';

  fixupPhase = ''
    runHook preFixup

    substituteInPlace $out/$outputdir/contents/ui/main.qml \
      --replace-fail "\$HOME/.local/$outputdir/contents/bin/lyrica" "${lib.getExe lyrica}" \
      --replace-fail "import QtWebSockets" "import \"file:${qt6.qtwebsockets}/lib/qt-6/qml/QtWebSockets\""

    runHook postFixup
  '';

  passthru.id = metadata.KPlugin.Id;

  meta = {
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    description = "KDE Plasma lyrics widget focused on simplicity and integration";
    homepage = "https://github.com/chiyuki0325/lyrica";
    license = lib.licenses.mit;
  };
})
