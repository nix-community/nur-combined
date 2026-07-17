 { stdenv, lib
, fetchurl
, mesa
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "llama-cpp-vulkan-prism";
  version = "b9594-38c66ad";

  src = fetchurl {
    url = "https://github.com/PrismML-Eng/llama.cpp/releases/download/prism-${version}/llama-prism-${version}-bin-ubuntu-vulkan-x64.tar.gz";
    hash = "sha256-Szb0TyswC1mABBQGB0COyCXPzmEKKrSiYg7Iy+Fl6tU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    mesa
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir $out/bin $out/lib -p
    mv llama-prism-${version}/*.so* $out/lib
    mv llama-prism-${version}/* $out/bin
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/PrismML-Eng/llama.cpp";
    description = "LLama.cpp with Q2 support";
    platforms = platforms.linux;
  };
}

