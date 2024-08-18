{ config
, lib
, stdenv
, fetchFromGitHub
, botan3
, qt6
}:

stdenv.mkDerivation rec {
  pname = "velocity";
  version = "8889a6d";

  src = fetchFromGitHub {
    owner = "hetelek";
    repo = "Velocity";
    rev = "8889a6d4c52dc9efa5c2ade7673c160d802175c1";
    hash = "sha256-aGV926VZtmzDt+5AbD7KhFTsfIopFzLqytvXtmiQBls=";
  };

  nativeBuildInputs = [ botan3.dev qt6.full ];
  buildInputs = [ botan3.dev qt6.full ];  

  buildPhase = ''
    substituteInPlace XboxInternals/XboxInternals.pro Velocity/Velocity.pro \
      --replace /usr/include/botan-3 ${botan3.dev}/include/botan-3 \
      --replace /usr/lib/libbotan-3.so.0 ${botan3}/lib/libbotan-3.so

    make release
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp Velocity/Velocity $out/bin/velocity
  '';

  meta = with lib; {
    description = "Xbox 360 File Manager";
    hompage = "https://github.com/hetelek/Velocity";
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
