{ stdenv, lib, fetchgit, autoreconfHook, python, texinfo }:
stdenv.mkDerivation rec {
  name = "simulavr-${version}";
  version = "1.2dev";
  src = fetchgit {
    url = "https://git.savannah.nongnu.org/git/simulavr.git";
    rev = "e53413b230637b75e1cfa5c316e988480f5cea14";
    sha256 = "1cljbajcr3ahfs3anpadw5vdv83qrfyc1v53qiw8abqsgwyzf7d1";
    fetchSubmodules = false;
  };
  buildInputs = [ autoreconfHook python texinfo ];
  meta = with lib; {
    description = "Simulavr is a simulator for the Atmel AVR family of 8-bit risc microcontrollers.";
    homepage = https://www.nongnu.org/simulavr/;
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
  };
}
