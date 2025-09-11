{ lib
, stdenv
, fetchurl
, cmake
, zlib
, freetype
, libjpeg
, libtiff
, libpng
}:

stdenv.mkDerivation rec {
  pname = "libaesgm";
  version = "20090429";

  src = fetchurl {
    url = "https://src.fedoraproject.org/rpms/libaesgm/archive/libaesgm-20090429-3_fc14/libaesgm-libaesgm-20090429-3_fc14.tar.gz";
    hash = "";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    zlib
    freetype
    libjpeg
    libtiff
    libpng
  ];

  meta = with lib; {
    description = "A Fast and Free C++ Library for Creating, Parsing an Manipulating PDF Files and Streams";
    homepage = "https://src.fedoraproject.org/rpms/libaesgm";
    # upstream (http://gladman.plushost.co.uk/oldsite/AES/index.php) is not accessible
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ wineee ];
  };
}

