{ lib
, stdenv
, fetchFromGitHub
, vapoursynth
, cmake
, pkgconfig
, tbb
, git
, fftwFloat
}:

stdenv.mkDerivation rec {
  pname = "vapoursynth-neofft3d";
  version = "11";

  src = fetchFromGitHub {
    owner = "HomeOfVapourSynthEvolution";
    repo = "neo_FFT3d";
    rev = "r${version}";
    sha256 = "sha256-m+Gu2ufwL3GelEQgPCGAaqP9At/D3Mi40bFYWE1YoDc=";
  };

  NIX_LDFLAGS = "-rpath ${lib.makeLibraryPath [ fftwFloat ]}";

  dontPatchELF = true;

  nativeBuildInputs = [
    cmake
    pkgconfig
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
