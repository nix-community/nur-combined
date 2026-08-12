{
  lib,
  stdenv,
  fetchFromGitHub,
  vapoursynth,
  meson,
  ninja,
  pkg-config,
  maintainers,
  ...
}:
let
  pname = "vapoursynth-bwdif";
  version = "4.1";

  rev = "r${version}";
  hash = "sha256-wpALZMSKX+LvbPOL1DpqumfT1Ql4Kbi4Mi7U2nooZmQ=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "HomeOfVapourSynthEvolution";
    repo = "VapourSynth-Bwdif";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    vapoursynth
  ];

  installPhase = ''
    install -m755 -D libbwdif.so $out/lib/vapoursynth/libbwdif.so
    install -m755 -D libavx2.a $out/lib/vapoursynth/libavx2.a
    install -m755 -D libavx512.a $out/lib/vapoursynth/libavx512.a
  '';

  meta = {
    inherit maintainers;
    description = "Bwdif filter for VapourSynth.";
    homepage = "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bwdif";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
