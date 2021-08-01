{ lib
, stdenv
, mkDerivation
, fetchFromGitHub
, qmake
, pkg-config
, qtbase
, qttools
, qtquickcontrols2
, avahi
, clang_10
}:

mkDerivation {
  pname = "Protify";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "Protify";
    rev = "b324984386fb2bf8743de9608711d18624cc9889";
    sha256 = "0s13hqlic3dp65zmiyg77x2adgs8c9n6g2flwhsmw5imx4pdbddn";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ clang_10 qmake qtbase pkg-config qttools ];
  buildInputs = [ qtquickcontrols2 qtbase avahi ];
  qmakeFlags = [ "QMAKE_CXX=clang++" ];
  installFlags = [ "INSTALL_ROOT=$(out)" ];

  meta = with lib; {
    description = "The Qt gui frontend for FakeMicWavPlayer";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/ControlsForFake";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
