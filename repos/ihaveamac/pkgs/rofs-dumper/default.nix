{
  lib,
  stdenv,
  clang19Stdenv,
  gcc14Stdenv,
  fetchFromGitHub,
}:

let
  realStdenv = if stdenv.cc.isClang then clang19Stdenv else gcc14Stdenv;
in
realStdenv.mkDerivation rec {
  pname = "rofs-dumper";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "PabloMK7";
    repo = "rofs_dumper";
    rev = "v${version}";
    hash = "sha256-Y8pKQoDnqHHmE3ywBGucnnFW8J0rLhKRKN3rPRbUIww=";
  };

  buildPhase = ''
    ${realStdenv.cc.targetPrefix}c++ -std=c++20 main.cpp -o rofs_dump
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp rofs_dump${stdenv.hostPlatform.extensions.executable} $out/bin
  '';

  meta = with lib; {
    description = "Dumps 3DS ROFS containers (early format of romfs)";
    homepage = "https://github.com/PabloMK7/rofs_dumper";
    license = licenses.unlicense;
    platforms = platforms.all;
    mainProgram = "rofs_dump";
  };
}
