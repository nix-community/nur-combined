{ lib
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
    rev = "9b69a878d155b2a3b8f4a61ba09780b153f01779";
    sha256 = "0mqpb4shxk2nyhiy13aszhgax96zfh445945hr8k6rx9vv8mgpk6";
  };

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
