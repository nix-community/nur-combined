{
  lib,
  stdenv,
  fetchFromGitHub,
  gcc,
  maintainers,
  ...
}:
let
  pname = "vapoursynth-vsrawsource";
  version = "0.3.3-unstable-2017-01-31";

  rev = "5932753a9e5efa6abdb49b022f120b4703bed772";
  hash = "sha256-bNHuzNf0zmqw8UQFmfdRpJeDsKqITcg+IOD4pS+if/8=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "walisser";
    repo = "vsrawsource";
  };

  buildInputs = [
    gcc
  ];

  dontConfigure = true;

  buildPhase = ''
    cc -march=native -O2 -ffast-math -fomit-frame-pointer -shared -fPIC rawsource.c -o libvsrawsource.so
  '';

  installPhase = ''
    install -m755 -D libvsrawsource.so $out/lib/vapoursynth/libvsrawsource.so
  '';

  meta = {
    inherit maintainers;
    description = "Raw format reader for VapourSynth.";
    homepage = "https://github.com/JuniorIsAJitterbug/vsrawsource";
    license = lib.licenses.lgpl21Only;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
