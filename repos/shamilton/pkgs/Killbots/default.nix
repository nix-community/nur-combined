{ lib
, mkDerivation
, fetchFromGitLab
, cmake
, extra-cmake-modules
, qtbase
, kactivities
, libkdegames
}:

mkDerivation rec {
  pname = "Killbots";
  version = "20.08.2";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "games";
    repo = "killbots";
    rev = "v${version}";
    sha256 = "1pf71ha7lrikf26nvrqihnd373v0crfbk2d028pfiwg5si3jdw4s";
  };

  nativeBuildInputs = [ extra-cmake-modules cmake  ];

  buildInputs = [ libkdegames kactivities qtbase ];

  meta = with lib; {
    description = "Strategy Game with Robots";
    license = licenses.gpl2;
    homepage = "https://kde.org/applications/en/games/org.kde.killbots";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
