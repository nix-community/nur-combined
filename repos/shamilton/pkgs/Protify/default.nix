{ lib
, stdenv
, mkDerivation
, fetchFromGitHub
, qmake
, pkg-config
, qtbase
, qttools
, avahi
}:

mkDerivation {
  pname = "Protify";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "Protify";
    rev = "0e5d651c7e5e1bac8769f61454a22cadc4cca679";
    sha256 = "0rk3cx92i4l5x1ncrwrbicglr3bljc368s7gwhi7zzd3n5laky3d";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ qmake qtbase pkg-config qttools ];
  buildInputs = [ qtbase avahi ];
    
  installFlags = [ "INSTALL_ROOT=$(out)" ];

  meta = with lib; {
    description = "The Qt gui frontend for FakeMicWavPlayer";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/ControlsForFake";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
