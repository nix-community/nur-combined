{ pkgs
, lib
, stdenv
, mkDerivation
, fetchFromGitHub
, meson
, ninja
, pkg-config
, qtbase
, qtdeclarative
, qtgraphicaleffects
, qttranslations
, qtquickcontrols2
, pulseaudio
, libfake
, libvorbis
, libogg
, FakeMicWavPlayer
}:
mkDerivation {

  pname = "ControlsForFake";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "ControlsForFake";
    rev = "390813d95304106690394e70a7029241b688c5d2";
    sha256 = "169k8gsfmgab67zi4r85pzw4z7cx3a779i5xmskll2kc3ja04j2a";
  };

  # src = ./src.tar.gz;

  nativeBuildInputs = [ qttranslations qtbase pkg-config ninja meson ];

  buildInputs = 
          [ qtquickcontrols2 qtbase ] # Qt Deps
      ++  [ pulseaudio libfake libvorbis libogg FakeMicWavPlayer];

  postPatch = ''
    substituteInPlace controls-for-fake.desktop \
      --replace @Prefix@ "$out"
  '';

  meta = with lib; {
    description = "The Qt gui frontend for FakeMicWavPlayer";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/ControlsForFake";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
