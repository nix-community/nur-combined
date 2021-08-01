{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, cmake
, pulseaudio
, libfake
, libvorbis
, libogg
, argparse
}:

stdenv.mkDerivation {
  pname = "FakeMicWavPlayer";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "FakeMicWavPlayer";
    rev = "cf7a4572fa187ebf67bf93dc378ee939b8c46752";
    sha256 = "1ajgv9mjdrj8y83azvw3gkghlfsqcwmsm0ma55b1f5sfi81691ay";
  };

  nativeBuildInputs = [ pkg-config ninja meson cmake ];

  buildInputs = [ argparse libogg libvorbis pulseaudio libfake ];

  postPatch = ''
    substituteInPlace pkg-config/fakemicwavplayer.pc \
      --replace @Prefix@ $out
  '';

  meta = with lib; {
    description = "A pulseaudio client to play wav in a simulated microphone";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/FakeMicWavPlayer";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
