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
  version = "0.2.2";

  rev = "v${version}";
  hash = "sha256-w5CwiGV+sS3JAARe2/8vhbZe1ApSx9Rp+yiBlKjiYrs=";
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
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
