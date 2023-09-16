{ lib
, stdenv
, fetchFromGitHub
, vapoursynth
, cmake
, pkg-config
, tbb
, git
, fftwFloat
}:

stdenv.mkDerivation {
  pname = "vapoursynth-neofft3d";
  version = "unstable-2021-10-22";

  src = fetchFromGitHub {
    owner = "HomeOfAviSynthPlusEvolution";
    repo = "neo_FFT3d";
    rev = "23522f55a259c5b564fa9ffc721a95ac4e38fede";
    hash = "sha256-m+Gu2ufwL3GelEQgPCGAaqP9At/D3Mi40bFYWE1YoDc=";
  };

  NIX_LDFLAGS = "-rpath ${lib.makeLibraryPath [ fftwFloat ]}";

  dontPatchELF = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    git
    tbb
    vapoursynth
  ];

  installPhase = ''
    mkdir -p $out/lib/vapoursynth
    cp libneo-fft3d.so $out/lib/vapoursynth/libneo-fft3d.so
  '';

  meta = with lib; {
    description = "Neo FFT3D (forked from fft3dfilter) is a 3D Frequency Domain filter - strong denoiser and moderate sharpener.";
    homepage = "https://github.com/HomeOfAviSynthPlusEvolution/neo_FFT3D";
    license = licenses.gpl2;
    maintainers = [ "JuniorIsAJitterbug" ];
    platforms = platforms.all;
  };
}
