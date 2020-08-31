{ stdenv, python, fetchurl, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "iwd-autocaptiveauth";
  version = "0.2";

  src = fetchurl {
    url = "https://git.project-insanity.org/onny/py-iwd-autocaptiveauth/-/archive/master/py-iwd-autocaptiveauth-master.tar.gz";
    sha256 = "1k32w626g18phw2xpig1spr41zhzrk3clsw4nz2iv2jc2smvlyh0";
  };

  buildInputs  = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -av iwd-autocaptiveauth.py profiles $out/
    chmod 555 $out/iwd-autocaptiveauth.py
    makeWrapper $out/iwd-autocaptiveauth.py $out/bin/iwd-autocaptiveauth
  '';

  meta = with stdenv.lib; {
    description = "iwd automatic authentication to captive portals";
    homepage = "https://git.project-insanity.org/onny/py-iwd-autocaptiveauth";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
