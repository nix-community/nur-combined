{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
}:

stdenv.mkDerivation rec {
  pname = "libmts";
  version = "unstable-2024-05-21";

  src = fetchFromGitHub {
    owner = "ODDSound";
    repo = "MTS-ESP";
    rev = "2d7c013ebf4a076c35811e62293e8f819d053a91";
    hash = "sha256-qgVRr8KI8U3qoazS+jppdvP1s+EyjK5S82rBeJMKuh0=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [ stdenv.cc.cc.lib ];

  # dontConfigure = true;
  # dontBuild = true;

  outputs = [
    "out"
    "dev"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{etc,lib,include}
    install -v --mode=0777 -t $out/lib libMTS/Linux/x86_64/libMTS.so
    cp -va libMTS/MTS-ESP.conf $out/etc
    cp -va {Client,Master}/{*.cpp,*.h} $out/include
    runHook postInstall
  '';

  meta = {
    description = "A simple but versatile C/C++ library for adding microtuning support to audio and MIDI plugins";
    homepage = "https://github.com/ODDSound/MTS-ESP";
    license = lib.licenses.bsd0;
    # maintainers = with lib.maintainers; [ ];
    # mainProgram = "libmts";
    platforms = lib.platforms.all;
  };
}
