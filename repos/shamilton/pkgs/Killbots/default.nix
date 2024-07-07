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
  version = "23.04.0";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "games";
    repo = "killbots";
    rev = "v${version}";
    sha256 = "sha256-jkXSF3LJ8vZ6lN+T9uu+eQTBSOnFvk7Xv1mPizx6/yU=";
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
