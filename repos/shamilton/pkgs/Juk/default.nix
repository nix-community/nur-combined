{ lib
, mkDerivation
, fetchFromGitLab
, cmake
, extra-cmake-modules
, qtbase
, kactivities
, phonon
, taglib
}:

mkDerivation rec {
  pname = "juk";
  version = "22.12.2";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "multimedia";
    repo = "juk";
    rev = "v${version}";
    sha256 = "sha256-Jj5SflHOtDRCZlwX4uo6mLyhvI1/Bp9o8Rfhaq7eOGY=";
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
