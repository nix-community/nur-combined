{
  sources,
  lib,
  stdenv,
  rustPlatform,
  pkg-config,
  openssl,
  dbus,
  qt6,
}:
let
  metadata = builtins.fromJSON sources."plasmoid/metadata.json";
in
rustPlatform.buildRustPackage {
  inherit (sources) pname src;
  version = metadata.KPlugin.Version;
  cargoLock = sources.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    dbus
  ];

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    outputdir=share/plasma/plasmoids/${metadata.KPlugin.Id}
    mkdir -p $out/$outputdir
    cp -r plasmoid/* $out/$outputdir

    mkdir -p $out/$outputdir/contents/bin
    cp "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/lyrica" $out/$outputdir/contents/bin/lyrica
    substituteInPlace $out/$outputdir/contents/ui/main.qml \
      --replace-fail "import QtWebSockets" "import \"file:${qt6.qtwebsockets}/lib/qt-6/qml/QtWebSockets\"" \
      --replace-fail "\$HOME/.local" "$out"

    runHook postInstall
  '';

  meta = {
    description = "Linux desktop lyrics widget focused on simplicity and integration ";
    homepage = "https://github.com/chiyuki0325/lyrica";
    changelog = "https://github.com/chiyuki0325/lyrica/releases/tag/${sources.version}";
    license = lib.licenses.mit;
  };
}
