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
    sha256 = "1xxdjxx9phj9gim5wbyfr9mvdxydhxrhjwwd5irvsm27bspgz6k6";
  };

  nativeBuildInputs = [ qttranslations qtbase pkg-config ninja meson ];

  buildInputs = [ qtquickcontrols2 qtbase pulseaudio FakeMicWavPlayer ];

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
