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
  version = "20.08.2";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "multimedia";
    repo = "juk";
    rev = "v${version}";
    sha256 = "1miqa83bp1jxflzchg7bfn606487z3lx7iwpb26ns9dv472bdfbh";
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
