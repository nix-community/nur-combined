{
  stdenv,
  fetchgit,
  cmake,
  SDL2,
  sndio,
  jack2,
  xorg,
}:
let
  version = "0.2.0";
in
stdenv.mkDerivation {
  pname = "shadps4";
  inherit version;
  src = fetchgit {
    url = "https://github.com/shadps4-emu/shadPS4.git";
    rev = "v.${version}";
    fetchSubmodules = true;
    sha256 = "sha256-HNO/L2cMZVHTHczjKgUFVDDdWBnj7SKctGi+P7jATpQ=";
  };
  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    SDL2
    sndio
    jack2
    xorg.libXext
  ];
  installPhase = ''
    mkdir -p $out/bin
    cp shadps4 $out/bin
  '';
}
