{ stdenv, lib, fetchFromGitHub, cmake, openssl, lzo, zlib }:

stdenv.mkDerivation rec {
  pname = "epk2extract";
  version = "unstable";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "openlgtv";
    repo = pname;
    rev = "0914ee8ade32c03f70b9d69d837e57ef851a6431";
    sha256 = "03l9mzi1ak20w82619207yfniy71ydn2cd4fy1az2ph07z4vcn9f";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    openssl
    lzo
    zlib
  ];

  installPhase = ''
    mkdir -p "$out/bin"
    for exe in src/tools/idb_extract src/tools/lzhsenc src/tools/lzhs_scanner src/tools/jffs2extract src/epk2extract; do
      cp "$exe" "$out/bin/"
    done
  '';

  meta = with lib; {
    description = "epk2extract is a tool that can extract, decrypt, convert multiple file formats that can be found in LG TV sets and similar devices.";
    homepage = "https://github.com/openlgtv/epk2extract";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
