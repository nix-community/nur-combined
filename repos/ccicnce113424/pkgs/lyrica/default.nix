{
  sources,
  lib,
  stdenv,
  rustPlatform,
  pkg-config,
  openssl,
  dbus,
  qt6Packages,
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
    qt6Packages.qtdeclarative
    qt6Packages.qtwebsockets
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
