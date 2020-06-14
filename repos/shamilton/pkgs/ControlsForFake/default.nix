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
mkDerivation {

  pname = "ControlsForFake";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "ControlsForFake";
    rev = "master";
    sha256 = "0ijcxid2kfp1pq8d1893vfrzrk0j6pgs73y1d5xyc7lc37qv8jr5";
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
