{ lib
, stdenv
, fetchFromCodeberg
, cmake
}:

stdenv.mkDerivation rec {
  pname = "injectd";
  version = "1.0.1";

  src = fetchFromCodeberg {
    owner = "b6d5b38e0d7ae6bd0d951815cd92df43";
    repo = "injectd";
    rev = "v${version}";
    hash = "sha256-mBnMTiak0dyD9nWwjvbNFm18K2KqWcbonOd2Vl/3g2E=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A tool to inject custom boot messages into the console";
    homepage = "https://codeberg.org/b6d5b38e0d7ae6bd0d951815cd92df43/injectd";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "injectd";
  };
}
