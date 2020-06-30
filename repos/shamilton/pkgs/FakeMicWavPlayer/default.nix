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
, enableDebugging
}:
stdenv.mkDerivation rec {

  pname = "FakeMicWavPlayer";
  version = "unstable";
  debug = false;

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "FakeMicWavPlayer";
    rev = "master";
    sha256 = "1pqgy0pljqqcqwy5f3p61n7d2pc857wsajwd0h42c2bhn8hbnqd6";
  };

  nativeBuildInputs = [ pkg-config ninja meson cmake ];

  buildInputs = [ argparse libogg libvorbis pulseaudio libfake ];

  postPatch = ''
    substituteInPlace pkg-config/fakemicwavplayer.pc \
      --replace @Prefix@ $out
  '';

  mesonFlags = [ ( if debug then "--buildtype=debug" else "--buildtype=plain")  "-DUSE_SYSTEM_ARGPARSE=true" ];

  dontStrip = if debug then true else false;

  meta = with lib; {
    description = "A pulseaudio client to play wav in a simulated microphone";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/FakeMicWavPlayer";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
