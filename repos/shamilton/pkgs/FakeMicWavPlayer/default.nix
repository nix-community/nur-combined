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
    rev = "6920a243eb876c0f75625a0017bb433a377aa244";
    sha256 = "1q5bn7h28z0wzs115nql5arhbfap1vijx4h284jpfxj042xbzw6n";
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
