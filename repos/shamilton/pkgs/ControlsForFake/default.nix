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
    rev = "d8ac6d25963841692ce58b9a98ff25816135aed0";
    sha256 = "1qr040ilakvcbjdpg9mci66dhhvy3fl9r0c5ssafsbjjlzcim9gm";
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
