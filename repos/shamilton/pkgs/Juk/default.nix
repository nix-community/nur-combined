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
  version = "20.08.2";

  src = fetchurl {
    url = "mirror://kde/stable/release-service/20.08.2/src/juk-20.08.2.tar.xz";
    sha256 = "0q7cqwkdi8rrmd79d68ndcl2w4cjvgkdvgcz8qsw7i40ijnmk7xi";
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
