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
    rev = "9f522309f6caee8323dd3e56ce7efc8854d0b397";
    sha256 = "1i2yj8i05lq8mcq70maxvxcwbgp4mk5cy9274bw06q72i70ah1bv";
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
