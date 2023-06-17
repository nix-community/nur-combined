{ llvmPackages, 
  fetchurl,
  lib,
  autoPatchelfHook,
}:

# TODO: Fix RAYLIB, LLVM-STRIP, AR
llvmPackages.stdenv.mkDerivation rec {
  pname = "wasi-sdk";
  version = "20";

  src = fetchurl {
    url = "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-${version}/wasi-sdk-${version}.0-linux.tar.gz";
    hash = "sha256-cDATnUlaGfvsy5RJFQwrFTHhXY+3RBmHKnGadYCq0Pk=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [ llvmPackages.stdenv.cc.cc.lib ];

  sourceRoot = ".";

  dontBuild = true;
  installPhase = ''
    mkdir -p $out/
    cp -r ./wasi-sdk-20.0/* $out/
  '';

  meta = with lib; {
    homepage = "https://github.com/WebAssembly/wasi-sdk";
    description = "wasi-sdk";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = [ "Franciszek Łopuszański<franopusz2006@gmail.com>" ];
  };
}