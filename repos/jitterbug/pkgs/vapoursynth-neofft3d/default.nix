{
  maintainers,
  lib,
  stdenv,
  fetchFromGitHub,
  vapoursynth,
  cmake,
  ninja,
  pkg-config,
  tbb,
  git,
  ...
}:
let
  pname = "vapoursynth-neofft3d";
  version = "r12-unstable-2025-05-24";

  rev = "780dcdfb477c3e5195b1418b15a8b7eed89507ac";
  hash = "sha256-7HcUrL5PNYiyAC3RAVGnrXZG7h7CT7HSCwEV858BNkg=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "HomeOfAviSynthPlusEvolution";
    repo = "neo_FFT3d";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
  ];

  buildInputs = [
    git
    tbb
    vapoursynth
  ];

  installPhase = ''
    install -m755 -D libneo-fft3d.so $out/lib/vapoursynth/libneo-fft3d.so
  '';

  meta = {
    inherit maintainers;
    description = "Neo FFT3D (forked from fft3dfilter) is a 3D Frequency Domain filter - strong denoiser and moderate sharpener.";
    homepage = "https://github.com/HomeOfAviSynthPlusEvolution/neo_FFT3D";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
