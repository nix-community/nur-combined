{
  lib,
  stdenv,
  fetchFromGitHub,
  vapoursynth,
  meson,
  ninja,
  pkg-config,
  qt6,
  fftw,
  sqlite,
  maintainers,
  ...
}:
let
  pname = "vapoursynth-analog";
  version = "0-unstable-2026-01-23";

  rev = "5f7f5ee7c9fe57613e69bfc84a75d2a04d91f596";
  hash = "sha256-N+IQwQF6AxVI8cU9ptL4Z4YiW/k73IsXua2wBxwgg7A=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "JustinTArthur";
    repo = "VapourSynth-analog";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    qt6.qtbase
    qt6.wrapQtAppsHook
    vapoursynth
    fftw
    sqlite
  ];

  installPhase = ''
    install -m755 -D vsanalog.so $out/lib/vapoursynth/vsanalog.so
  '';

  meta = {
    inherit maintainers;
    description = "VapourSynth source and filters plugin for working with digitized analog video and signals.";
    homepage = "https://github.com/JustinTArthur/vapoursynth-analog";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
