{ stdenv, fetchurl
, gettext
, icu, pkgconfig }:

stdenv.mkDerivation rec {
  name = "dwdiff-${version}";
  version = "2.1.2";

  src = fetchurl {
    url = "https://os.ghalkes.nl/dist/dwdiff-${version}.tar.bz2";
    sha256 = "14n6z8n92zrgx6r6fwz3mcxzmwjmv4bww88bi99vpsv4j52zs09j";
  };

  outputs = [ "bin" "doc" "man" "out" ];

  nativeBuildInputs = [ gettext ];
  buildInputs = [ icu pkgconfig ];

  doCheck = true;

  postPatch = ''
    echo 'INSTALLDIRS="bindir docdir mandir"' >> config.pkg
  '';

  # otherwise it points to lib (which falls back to out) and out -> bin cycles
  configureFlags = [ "--localedir=\${bin}/share/locale" ];

  meta = with stdenv.lib; {
    description = "A diff program that operates word by word";
    homepage = https://os.ghalkes.nl/dwdiff.html;
    license = with licenses; [ gpl3 ];
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.all;
  };
}
