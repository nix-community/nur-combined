{ stdenv, lib, fetchFromGitHub, mbedtls, python2, perl }:
let
  version = "4.03";
  src = fetchFromGitHub {
    owner = "The-4n";
    repo = "4NXCI";
    rev = "v${version}";
    sha256 = "0n49sqv6s8cj2dw1dbcyskfc2zr92p27f1bdd6jqfbawv0fqr1wf";
  };

  mymbedtls = stdenv.mkDerivation {
    name = "mbedtls-${version}";
    version = "2.6.1";
    doCheck = false;
    inherit src;
    buildInputs = [ perl ];
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    makeFlags = [ "DESTDIR=$(out)" ];
    buildPhase = ''
      cp config.mk.template config.mk
      cd mbedtls
      make
    '';
  };
in stdenv.mkDerivation rec {
  name = "4nxci-${version}";

  inherit src version;
  buildPhase = ''
    cp config.mk.template config.mk
    sed -i 's#\(INCLUDE =\).*#\1${mymbedtls}/include#' Makefile
    sed -i 's#\(LIBDIR =\).*#\1${mymbedtls}/lib#' Makefile
    make 4nxci
  '';

  installPhase = ''
    install -m755 -D 4nxci $out/bin/4nxci
  '';

  #preInstall = ''
  #  mkdir -p $out/bin
  #'';

  buildInputs = [ mymbedtls ];

  meta = {
    description = "convert xci to nsp";
    license = lib.licenses.isc;
  };
}
