{ stdenv, 
  fetchFromGitHub,
  lib,
  autoPatchelfHook,
  gcc,
  glibc
}:

stdenv.mkDerivation rec {
  pname = "wasi-sdk";
  version = "20";
  
  src = fetchFromGitHub {
    owner = "WebAssembly";
    repo = "wasi-sdk";
    rev = "wasi-sdk-${version}";
    sha256 = "1rjh19g1mcvaixyp3fs6d9bfa1nqv5b6s6v1nb24q7wbb75y9m8x";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    gcc
    glibc
  ];

  sourceRoot = ".";

  dontBuild = true;
  installPhase = ''
    mkdir -p $out/
    cp -r ./source/* $out/
  '';

  meta = with lib; {
    homepage = "https://github.com/WebAssembly/wasi-sdk";
    description = "wasi-sdk";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = [ "Franciszek Łopuszański<franopusz2006@gmail.com>" ];
  };
}