{
  lib,
  stdenv,
  fetchFromGitHub,
  puredata,
}:
stdenv.mkDerivation rec {
  pname = "pd-midifile";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "pd-externals";
    repo = "midifile";
    tag = "v${version}";
    hash = "sha256-oxTf8/h0/2zzh1o+VriuOEJnZEA8+vcg6hDCYO8HvbI=";
  };

  nativeBuildInputs = [ puredata ];

  makeFlags = [
    "PDINCLUDEDIR=${puredata}/include/pd"
    "PDLIBDIR=${placeholder "out"}"
  ];

  meta = {
    description = "Read and write MIDI files (.mid) with Pd";
    homepage = "https://github.com/pd-externals/midifile";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ kugland ];
  };
}
