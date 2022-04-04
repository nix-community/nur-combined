{ pkgs ? import <nixpkgs> {} }:
with pkgs;

stdenv.mkDerivation (rec {
  name = "noise-suppression-for-voice-${version}";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "werman";
    repo = "noise-suppression-for-voice";
    rev = "2aa466a51c330f81a94697fdc7f2275a1788a394";
    sha256 = "0r9bh4l7ncnf6g64y5sq2m8a1753qqvrbjlpywqzkjgzssk42js5";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    homepage = https://github.com/werman/noise-suppression-for-voice;
    description = "Noise suppression plugin based on Xiph's RNNoise";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
})
