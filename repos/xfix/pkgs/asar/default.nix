{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "asar";
  version = "1.81";
  src = fetchFromGitHub {
    owner = "RPGHacker";
    repo = pname;
    rev = "v${version}";
    sha256 = "nbVb6Y7Plr2EgDWzNMA8I2m3QPNAVfyCMWEd519fUco=";
  };
  nativeBuildInputs = [ cmake ];
  cmakeDir = "../src";
  installPhase = ''
    mkdir -p $out/bin
    cp asar/asar-standalone $out/bin/asar
  '';
  meta = with lib; {
    description = "SNES assembler";
    homepage = "https://github.com/RPGHacker/asar";
    license = [ licenses.gpl3Plus ]; 
    platforms = platforms.linux;
  };
}
