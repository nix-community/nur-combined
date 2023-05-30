{ stdenv
, lib
, fetchurl
, gnumake
, cmake
}:

stdenv.mkDerivation rec {
  name = "funchook";
  version = "1.1.2";

  src = fetchurl {
    url = "https://github.com/kubo/funchook/releases/download/v1.1.2/funchook-1.1.2.tar.gz";
    sha256 = "0c96w4c0jqq9yqpcp6p3vbicl51bqc688pc0bg629fyiinaas4wf";
  };

  nativeBuildInputs = [
    gnumake
    cmake
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_INSTALL_PREFIX=$out"
  ];

  meta = with lib; {
    description = "Hook function calls by inserting jump instructions at runtime";
    homepage = "https://github.com/kubo/funchook/";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
