{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  name = "clearsans-1.00";
  src = fetchzip {
    url = "https://01.org/sites/default/files/downloads/${name}.zip";
    sha256 = "0z89ws8kvsppisk0bc0ifpcz99j4138adr16z3rs991s9w7fb4ik";
    stripRoot = false;
  };
  buildCommand = ''
    install --target $out/share/fonts/truetype/ -D $src/TTF/*.ttf 
  '';

  meta = with stdenv.lib; {
    description = "A versatile OpenType font for screen, print and Web";
    homepage = "https://01.org/clear-sans";
    license = licenses.asl20;
  };
}
