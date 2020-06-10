{ lib
, mkDerivation
, fetchurl
, cmake
, extra-cmake-modules
, qtbase
, kactivities
, libkdegames
}:
mkDerivation {

  pname = "Killbots";
  version = "19.12.3";

  src = fetchurl {
      url = "mirror://kde/stable/release-service/19.12.3/src/killbots-19.12.3.tar.xz";
      sha256 = "3c5dc7e1f27036d2584f6ee58bf3bbffd9e56a467f30a8e2eab9e1bda1e7d4a3";
      name = "killbots-19.12.3.tar.xz";
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
