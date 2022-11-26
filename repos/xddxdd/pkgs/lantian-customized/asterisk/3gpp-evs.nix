{ stdenv
, lib
, fetchurl
, unzip
, ...
} @ args:

stdenv.mkDerivation rec {
  pname = "3gpp-evs";
  version = "16.1.0";
  src = fetchurl {
    url = "https://www.etsi.org/deliver/etsi_ts/126400_126499/126443/16.01.00_60/ts_126443v160100p0.zip";
    sha256 = "sha256-KlRADPdBIrFqj9gGwlTa9iI1VQ1uRFJ8dfe6ilJMXAY=";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    unzip ${src}
    unzip 26443-cc0_d80_e41_f21_g10-ANSI-C_source_code.zip
  '';
  sourceRoot = "c-code";

  NIX_CFLAGS_COMPILE = "-DNDEBUG -fPIC";
  makeFlags = [ "DEBUG=0" "RELEASE=1" ];

  installPhase = ''
    mkdir -p $out/lib $out/include/3gpp-evs
    cp --target-directory=$out/include/3gpp-evs ./lib_*/*.h

    rm ./build/decoder.o
    cc -shared -o $out/lib/lib3gpp-evs.so ./build/*.o
  '';

  # meta = with lib; {
  #   description = "G.729 and G.723.1 codecs for Asterisk (Only G.729 is enabled)";
  #   homepage = "https://github.com/arkadijs/asterisk-g72x";
  #   license = licenses.unfreeRedistributable;
  # };
}
