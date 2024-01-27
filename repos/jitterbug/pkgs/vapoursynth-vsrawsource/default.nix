{ lib
, stdenv
, fetchFromGitHub
, gcc
}:

stdenv.mkDerivation rec {
  pname = "vapoursynth-vsrawsource";
  version = "5932753a9e5efa6abdb49b022f120b4703bed772";

  src = fetchFromGitHub {
    rev = version;
    owner = "walisser";
    repo = "vsrawsource";
    sha256 = "sha256-bNHuzNf0zmqw8UQFmfdRpJeDsKqITcg+IOD4pS+if/8=";
  };

  buildInputs = [
    gcc
  ];

  dontConfigure = true;

  buildPhase = ''
    cc -march=native -O2 -ffast-math -fomit-frame-pointer -shared -fPIC rawsource.c -o libvsrawsource.so
  '';

  installPhase = ''
    mkdir -p $out/lib/vapoursynth
    ls -lh
    cp libvsrawsource.so $out/lib/vapoursynth/libvsrawsource.so
  '';

  meta = with lib; {
    description = "Raw format reader for VapourSynth.";
    homepage = "https://github.com/JuniorIsAJitterbug/vsrawsource";
    license = licenses.lgpl21Only;
    maintainers = [ "JuniorIsAJitterbug" ];
    platforms = platforms.linux;
    downloadPage = "https://github.com/JuniorIsAJitterbug/vsrawsource";
  };
}
