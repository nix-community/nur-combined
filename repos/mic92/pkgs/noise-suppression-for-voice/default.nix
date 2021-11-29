{ stdenv, fetchFromGitHub, cmake, lib }:

stdenv.mkDerivation {
  name = "noise-suppression-for-voice";
  src = fetchFromGitHub {
    owner = "werman";
    repo = "noise-suppression-for-voice";
    rev = "69224530674e71118ad58fa333ebcb6e09847a4a";
    sha256 = "sha256-uMlj9PxI3MY/XeY2Ows/7uu3uZPYsUGGAS+xdO9G2zs=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = with lib; {
    description = "Noise suppression plugin based on Xiph's RNNoise";
    homepage = "https://github.com/werman/noise-suppression-for-voice";
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
