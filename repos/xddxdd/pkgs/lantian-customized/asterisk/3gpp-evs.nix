{
  stdenv,
  lib,
  fetchurl,
  unzip,
}:
stdenv.mkDerivation rec {
  pname = "3gpp-evs";
  version = "16.1.0";
  src = fetchurl {
    url = "https://web.archive.org/web/20240220062854/https://www.etsi.org/deliver/etsi_ts/126400_126499/126443/16.01.00_60/ts_126443v160100p0.zip";
    hash = "sha256-KlRADPdBIrFqj9gGwlTa9iI1VQ1uRFJ8dfe6ilJMXAY=";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    unzip $src
    unzip 26443-cc0_d80_e41_f21_g10-ANSI-C_source_code.zip
  '';
  sourceRoot = "c-code";

  NIX_CFLAGS_COMPILE = "-DNDEBUG -fPIC";
  makeFlags = [
    "DEBUG=0"
    "RELEASE=1"
  ];

  installPhase = ''
    mkdir -p $out/lib $out/include/3gpp-evs
    cp --target-directory=$out/include/3gpp-evs ./lib_*/*.h

    rm ./build/decoder.o
    cc -shared -o $out/lib/lib3gpp-evs.so ./build/*.o
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "3GPP EVS Reference Implementation";
    homepage = "https://webapp.etsi.org/key/key.asp?GSMSpecPart1=26&GSMSpecPart2=443";
    license = lib.licenses.unfree;
  };
}
