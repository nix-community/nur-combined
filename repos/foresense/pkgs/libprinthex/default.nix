{
  lib,
  stdenv,
  fetchFromGitHub,
  binutils,
  clang,
}:

stdenv.mkDerivation rec {
  pname = "libprinthex";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "rstemmer";
    repo = "libprinthex";
    rev = "v${version}";
    hash = "sha256-rZMrBsq/GpSOCVeBOsBs4xiO0tzhBx4ItHWuGMqw2cQ=";
  };

  outputs = [
    "out"
    "dev"
  ];

  outputBin = "dev";

  nativeBuildInputs = [
    binutils
    clang
  ];

  buildPhase = ''
    clang -O2 -std=c99 -I. -c -o printhex.o printhex.c
    ar qfs libprinthex.a printhex.o
  '';

  installPhase = ''
    mkdir -p $out/{lib,include}
    install -m 644 -v libprinthex.a $out/lib
    install -m 644 -v printhex.h $out/include
  '';

  meta = {
    description = "A library to print a buffer as typical hex-view with highlighted regions on the console screen";
    homepage = "https://github.com/rstemmer/libprinthex";
    changelog = "https://github.com/rstemmer/libprinthex/blob/${src.rev}/CHANGELOG";
    license = lib.licenses.gpl3Only;
    mainProgram = "libprinthex";
    platforms = lib.platforms.all;
  };
}
