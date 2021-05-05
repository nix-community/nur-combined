{ lib, stdenv, fetchFromGitHub, ... }@inputs:

stdenv.mkDerivation {
  pname = "sysfo";
  version = "1.0";

  # src = inputs.sysfo;
  src = fetchFromGitHub {
    owner = "ethancedwards8";
    repo = "sysfo";
    rev = "fd620e7ffd81c8fad7210ad3c99d92e2307a679a";
    sha256 = "IAZGz5mHTLIOP0RXuyXTJAdNT0fW6PhyjZptJ1ssL3Y=";
  };
  buildPhase = ''
    make
  '';

  checkPhase = ''
    $out/bin/sysfo -V > /dev/null
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp sysfo $out/bin/sysfo
  '';

  meta = with lib; {
    description = "A neofetch inspired project written in C to give you information about your system";
    homepage    = "https://github.com/ethancedwards8/sysfo";
    license     = licenses.gpl2Plus;
    platforms   = platforms.all;
    maintainers = with maintainers; [ ethancedwards8 ];
  };
}
