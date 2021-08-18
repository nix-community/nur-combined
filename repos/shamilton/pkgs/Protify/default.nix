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
, cppzmq
, zeromq
, clang_10
}:

mkDerivation {
  pname = "Protify";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "Protify";
    rev = "1ad301e842fe1cd440eddf30a5f8370971e796eb";
    sha256 = "1awdnzxfbaz0mmqxwv10n4gcrdr58fhcfa0fjniwnyjf36rv0440";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ clang_10 qmake qtbase pkg-config qttools ];
  buildInputs = [ qtquickcontrols2 qtbase avahi cppzmq zeromq ];
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
