{
  sources,
  lib,
  rustPlatform,
  pkg-config,
  jq,
  openssl,
  qt6,
  fetchpatch2,
}:
let
  metadata = lib.importJSON sources.extract."frontend/kde/metadata.json";
in
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (sources) pname src;
  cargoLock = sources.cargoLock."Cargo.lock";
  inherit ((lib.importTOML sources.extract."Cargo.toml").package) version;

  nativeBuildInputs = [
    pkg-config
    jq
  ];

  buildInputs = [
    openssl
  ];

  patches = [
    (fetchpatch2 {
      url = "https://github.com/chiyuki0325/lyrica/pull/26.patch";
      hash = "sha256-8lxQ10KRwauYynW8rcbZlujyqmwBWK49ddHYYj3Xwm0=";
    })
  ];

  postInstall = ''
    outputdir=share/plasma/plasmoids/${metadata.KPlugin.Id}
    mkdir -p $out/$outputdir/contents
    cp -r frontend/kde/contents/* $out/$outputdir/contents

    jq '.KPlugin.Version = "${finalAttrs.version}"' \
      frontend/kde/metadata.json > $out/$outputdir/metadata.json
  '';

  postFixup = ''
    substituteInPlace $out/$outputdir/contents/ui/main.qml \
      --replace-fail "\$HOME/.local/$outputdir/contents/bin/lyrica" "$out/bin/lyrica" \
      --replace-fail "import QtWebSockets" "import \"file:${qt6.qtwebsockets}/lib/qt-6/qml/QtWebSockets\""
  '';

  passthru.id = metadata.KPlugin.Id;

  meta = {
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    description = "KDE Plasma lyrics widget focused on simplicity and integration";
    homepage = "https://github.com/chiyuki0325/lyrica";
    license = lib.licenses.mit;
  };
})
