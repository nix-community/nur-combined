{ stdenv, lib, fetchFromGitHub
, debug ? false
, optimize ? (!debug)
}:

stdenv.mkDerivation rec {
  pname = "loguru";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "emilk";
    repo = "loguru";
    rev = "v${version}";
    sha256 = "0g8j6811nm9kf3g49sq6dygh4q8w838a6p05x5hyvpk2w8kpr7nx";
  };

  cFlags = "-fPIC" +
    lib.optionalString debug " -g" +
    lib.optionalString optimize " -O2";
  dontStrip = debug;
  buildPhase = ''
    $CXX -std=c++11 -o libloguru.so -shared -pthread ${cFlags} loguru.cpp
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp libloguru.so $out/lib/

    mkdir -p $out/include
    cp ./loguru.hpp $out/include/

    mkdir -p $out/lib/pkgconfig
    cat <<EOF >>$out/lib/pkgconfig/loguru.pc
prefix=$out
libdir=$out/lib
includedir=$out/include

Name: loguru
Description: A lightweight and flexible C++ logging library.
Version: ${version}
Libs: -L$out/lib -lloguru
Cflags: -I$out/include
EOF
  '';

  meta = with lib; {
    description = "A header-only C++ logging library";
    longDescription = "A lightweight and flexible C++ logging library.";
    homepage = https://github.com/emilk/loguru;
    platforms = platforms.all;
    license = licenses.publicDomain;
    broken = false;
  };
}
