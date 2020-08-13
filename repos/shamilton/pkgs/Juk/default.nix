{ lib
, mkDerivation
, fetchurl
, cmake
, extra-cmake-modules
, qtbase
, kactivities
, phonon
, taglib
}:
mkDerivation {

  pname = "juk";
  version = "19.12.3";

  src = fetchurl {
    url = "mirror://kde/stable/release-service/19.12.3/src/juk-19.12.3.tar.xz";
    sha256 = "4bc4210d223afc23cb6edc9262eceee038ecc6243a550698e676230168943611";
    name = "juk-19.12.3.tar.xz";
  };

  nativeBuildInputs = [ extra-cmake-modules cmake  ];

  buildInputs = [ taglib phonon kactivities qtbase ];

  meta = with lib; {
    description = "Audio jukebox app, supporting collections of MP3, Ogg Vorbis and FLAC audio files";
    license = licenses.gpl2;
    homepage = "https://kde.org/applications/en/multimedia/org.kde.juk";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
