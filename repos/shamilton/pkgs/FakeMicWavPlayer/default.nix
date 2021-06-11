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
    rev = "c5ecb7cd0c2cb142806dcbbc8e2f8ea5afb6c28c";
    sha256 = "17vlsihpkfkl408w1cyjm8zxv07v5gcs1q46ab39l4g2rdxg5072";
  };

  # src = ./src.tar.gz;

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
