{
  lib,
  stdenv,
  autoPatchelfHook,
  makeWrapper,
  libxkbcommon,
  libxcb,
  wayland,
  libglvnd,
  vulkan-loader,
  dbus,
  libsecret,
}:
{
  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [
    stdenv.cc.cc.lib
    libxkbcommon
  ];
  runtimeDependencies = [
    libxcb
    wayland
    libglvnd
    vulkan-loader
    dbus
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp -r usr/share "$out/share"
    install -m755 usr/bin/pebrel usr/bin/pebrel-hook "$out/bin/"
    substituteInPlace "$out/share/applications/io.github.kuddev.pebrel.desktop" \
      --replace-fail 'Exec=pebrel' "Exec=$out/bin/pebrel"
    wrapProgram "$out/bin/pebrel" \
      --prefix PATH : ${lib.makeBinPath [ libsecret ]}
    runHook postInstall
  '';
}
