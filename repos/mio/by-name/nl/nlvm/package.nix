{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
  zstd,
  ncurses,
  libxml2,
  libffi,
}:

stdenv.mkDerivation rec {
  pname = "nlvm";
  version = "0-unstable-2026-08-14";

  src = fetchurl {
    url = "https://github.com/arnetheduck/nlvm/releases/download/continuous/nlvm-linux-3b5d285.tar.xz";
    hash = "sha256-/K79wnKLo55Gd7RAFUiMGFxGyMF+DNRbR2uZ0aAVpoI=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    zlib
    zstd
    ncurses
    libxml2
    libffi
    stdenv.cc.cc.lib
  ];

  sourceRoot = "nlvm-linux-3b5d285";

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -a . $out/
    ln -s $out/nlvm $out/bin/nlvm
    runHook postInstall
  '';

  meta = {
    description = "LLVM-based Nim compiler with wasm32 support";
    homepage = "https://github.com/arnetheduck/nlvm";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "nlvm";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
