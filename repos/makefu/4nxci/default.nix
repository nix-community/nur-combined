{ stdenv, lib, fetchFromGitHub, mbedtls, python2 }:
let
  
  mymbedtls = lib.overrideDerivation mbedtls (old: rec {
    name = "mbedtls-${version}";
    version = "2.13.0";
    src = fetchFromGitHub {
      owner = "ARMmbed";
      repo = "mbedtls";
      rev = name;
      sha256 = "1257kp7yxkwwbx5v14kmrmgk1f9zagiddg5alm4wbj0pmgbrm14j";
    };
    buildInputs = old.buildInputs ++ [ python2 ];
    postConfigure = ''
      perl scripts/config.pl set MBEDTLS_CMAC_C
    '';
    doCheck = false;

  });
in stdenv.mkDerivation rec {
  name = "4nxci-${version}";
  version = "1.30";

  src = fetchFromGitHub {
    owner = "The-4n";
    repo = "4NXCI";
    rev = "v${version}";
    sha256 = "0nrd19z88iahxcdx468lzgxlvkl65smwx8f9s19431cszyhvpxyh";
  };

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
