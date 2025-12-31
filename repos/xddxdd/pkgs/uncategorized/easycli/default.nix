{
  lib,
  sources,
  stdenv,
  autoPatchelfHook,
  dpkg,
  makeWrapper,
  webkitgtk_4_1,
  glib-networking,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "easycli";
  inherit (sources.easycli-amd64) version src;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = [
    webkitgtk_4_1
    glib-networking
  ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src .

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/* $out/

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Desktop GUI from CLIProxyAPI";
    homepage = "https://github.com/router-for-me/EasyCLI";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "easycli";
  };
})
