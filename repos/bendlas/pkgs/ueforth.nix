{ lib, gcc12Stdenv, fetchFromGitHub
, nodejs, python3
}:

gcc12Stdenv.mkDerivation rec {
  pname = "ueforth";
  ## https://github.com/flagxor/ueforth/commit/8e46c227aca17f4d0d0eb5ab71af6c88298e35cd
  version = "7.0.7.15-pre";
  src = fetchFromGitHub {
    owner = "flagxor";
    repo = "eforth";
    rev = "fa56ecf59d991a279d4a0987db51a1f56f44415b";
    sha256 = "sha256-XL+GhjKOwC580AE66NVGbNw1jpiMaOSCWPWJxJ8014I=";
  };

  postPatch = ''
    sed -i 's_/usr/bin/nodejs_${nodejs}/bin/node_' Makefile
    sed -i 's_/usr/bin/env nodejs_${nodejs}/bin/node_' **/*.js
    sed -i 's_/usr/bin/env python_${python3}/bin/python_' **/*.py
  '';

  buildPhase = ''
    make "REVISION=${src.rev}" out/posix/ueforth
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/ueforth
    cp out/posix/ueforth $out/bin
    cp -R common posix $out/share/ueforth/
  '';

  meta = {
    description = "µEforth, an EForth inspired Forth bootstraped from a minimalist C kernel";
    homepage = "https://github.com/flagxor/eforth/tree/main/ueforth";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };

}
