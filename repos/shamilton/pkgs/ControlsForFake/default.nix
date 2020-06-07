{ pkgs
, lib
, mkDerivation
, fetchFromGitHub
, meson
, ninja
, pkg-config
, qtbase
, qttranslations
, qtquickcontrols2
, FakeMicWavPlayer
, pulseaudio
}:
mkDerivation rec {

  pname = "ControlsForFake";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "ControlsForFake";
    rev = "master";
    sha256 = "0jvvmc7mb8q2qj76i9smbqd26ba31smqhbsjgpl99bn93lbl0vmx";
  };

  nativeBuildInputs = [ qttranslations qtbase pkg-config ninja meson ];

  buildInputs = [ qtquickcontrols2 qtbase pulseaudio FakeMicWavPlayer ];

  meta = with lib; {
    description = "The Qt gui frontend for FakeMicWavPlayer";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/ControlsForFake";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
