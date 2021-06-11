{ stdenv, lib, fetchFromGitHub, cmake, openssl, lzo, zlib }:

stdenv.mkDerivation rec {
  pname = "epk2extract";
  version = "unstable";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "openlgtv";
    repo = pname;
    rev = "9d6a7288122fa6e788d529530e3807188c888e2a";
    sha256 = "1f09r046jyxg8725wvdnxxj4jp4b1bwa40b41fljj9094hi3kx7l";
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
