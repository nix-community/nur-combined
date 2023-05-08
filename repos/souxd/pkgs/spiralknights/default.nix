{ stdenv
, lib
, fetchurl
, jdk
, libXcursor
}:

stdenv.mkDerivation {
  name = "spiralknights";
  src = fetchurl {
    url = "https://gamemedia.spiralknights.com/spiral/client/spiral-install.bin";
    sha256 = "125ksx0449b6qx60xvv7m9x6s4yrmx9pkgw30wcqc8gzw1a1fx91";
  };

  nativeBuildInputs = [ jdk ];

  meta = with lib; {
    license = licenses.unfree;
    broken = true;
  };
}
