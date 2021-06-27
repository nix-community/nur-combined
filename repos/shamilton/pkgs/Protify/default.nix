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
}:

mkDerivation {
  pname = "Protify";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "Protify";
    rev = "dad9d1248b2677d125faba94817de93af4c6391f";
    sha256 = "0j5j5y4ywirr9jdjy25q9mzkfd1rfx10gw1priw15sz36i4wg0lp";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ qmake qtbase pkg-config qttools ];
  buildInputs = [ qtquickcontrols2 qtbase avahi ];
    
  installFlags = [ "INSTALL_ROOT=$(out)" ];

  meta = with lib; {
    description = "The Qt gui frontend for FakeMicWavPlayer";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/ControlsForFake";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
