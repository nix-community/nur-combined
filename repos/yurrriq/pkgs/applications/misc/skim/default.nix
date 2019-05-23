{ stdenv, fetchurl, undmg }:

stdenv.mkDerivation rec {
  name = "skim-${version}";
  version = "1.4.41";

  src = fetchurl {
    url = "https://downloads.sourceforge.net/skim-app/Skim/Skim-${version}/Skim-${version}.dmg";
    sha256 = "0f8g1z4wg0bcsl8x50iq76x561w3dl1qzydx6vhhhr6rdd84k7si";
  };

  buildInputs = [ undmg ];

  installPhase = ''
    install -dm755 "$out/Applications/Skim.app"
    cp -R . "$_"
    chmod a+x "$_/Contents/MacOS/Skim"
  '';

  meta = with stdenv.lib; {
    description = "PDF reader and note-taker for OS X";
    homepage = "https://skim-app.sourceforge.io";
    repositories.svn = "http://svn.code.sf.net/p/skim-app/code/trunk";
    license = licenses.bsd2;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ yurrriq ];
  };
}
