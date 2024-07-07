{ lib
, stdenv
, mkDerivation
, fetchFromGitHub
, cmake
, pkg-config
, qtbase
, qtwebsockets
}:
mkDerivation rec {
  pname = "qcoro";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "danvratil";
    repo = "qcoro";
    rev = "v${version}";
    sha256 = "sha256-C4k5ClsMwzxURAQBGV5WBwlRr5N0SvUMJobZ+ROT0EY=";
  };

  nativeBuildInputs = [ cmake qtbase pkg-config ];

  buildInputs = [ qtbase qtwebsockets ]; # Qt Deps

  cmakeFlags = [
    "-DQCORO_DISABLE_DEPRECATED_TASK_H=ON"
  ];

  meta = with lib; {
    description = "The Qt gui frontend for FakeMicWavPlayer";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/ControlsForFake";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
