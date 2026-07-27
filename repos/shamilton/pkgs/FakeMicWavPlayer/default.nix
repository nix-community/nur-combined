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
# , nix-gitignore
}:

stdenv.mkDerivation {
  pname = "FakeMicWavPlayer";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "FakeMicWavPlayer";
    rev = "ee7134c989628c829590261824e76e8f35a0fbc5";
    sha256 = "sha256-aKXDOJd8fxwwE17jSJy/stfOJzcd83euczxy0Btt8TE=";
  };
  # src = nix-gitignore.gitignoreSource [] ~/GIT/FakeMicWavPlayer;

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
