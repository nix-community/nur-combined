{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation rec {
  meta = with lib; {
    description = "A modern, full-featured terminal text editor, with zero configuration";
    homepage = "https://github.com/sinelaw/fresh";
    license = licenses.gpl2Only;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "fresh";
  };

  pname = "fresh";
  version = "0.2.21";

  src = fetchurl {
    url = "https://github.com/sinelaw/fresh/releases/download/v${version}/fresh-editor-x86_64-unknown-linux-gnu.tar.xz";
    hash = "sha256-CxXZ9EUmtQZQ2wIa8FQb6Y97R5EwX1YJzktYtxzD0No=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/fresh
    cp -a ./* $out/opt/fresh/

    mkdir -p $out/bin
    ln -s $out/opt/fresh/fresh $out/bin/fresh

    runHook postInstall
  '';
}