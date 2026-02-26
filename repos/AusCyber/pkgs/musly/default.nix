{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  eigen,
  ffmpeg,
  libresample,
  kissfft,
  source
}:

stdenv.mkDerivation {
  pname = "musly";
#  version = "0.1-unstable-2019-09-05";

  outputs = [
    "bin"
    "dev"
    "out"
    "doc"
  ];

  inherit (source) src version;

  patches = [
    # Fix build with FFmpeg 7, C++17, and external libresample and kissfft
    # https://github.com/dominikschnitzer/musly/pull/53
    # Last commit omitted, as it is a large non‐functional removal
  #  ./0001-Fix-build-with-FFmpeg-7.patch
  #  ./0002-Fix-build-with-C-17.patch
  #  ./0003-Modernize-CMake-build-system.patch
  #  ./0004-Use-pkg-config-to-find-libresample-and-kissfft.patch
  ];

  nativeBuildInputs = [
#    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    eigen
    ffmpeg
    libresample
    kissfft
  ];

  doCheck = true;

  meta = {
    homepage = "https://www.musly.org";
    description = "Fast and high-quality audio music similarity library written in C/C++";
    longDescription = ''
      Musly analyzes the the audio signal of music pieces to estimate their similarity.
      No meta-data about the music piece is included in the similarity estimation.
      To use Musly in your application, have a look at the library documentation
      or try the command line application included in the package and start generating
      some automatic music playlists right away.
    '';
    license = lib.licenses.mpl20;
#    maintainers = with lib.maintainers; [ ggpeti ];
    platforms = lib.platforms.unix;
    mainProgram = "musly";
  };
}

