{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "tt-rss";
  version = "2020-09-23";
  rev = "d0ed7890df";

  src = fetchurl {
    url = "https://git.tt-rss.org/git/tt-rss/archive/${rev}.tar.gz";
    sha256 = "1b2fczd41bqg9bq37r99svrqswr9qrp35m6gn3nz032yqcwc22ij";
  };

  installPhase = ''
    mkdir $out
    cp -ra * $out/
  '';

  meta = with stdenv.lib; {
    description = "Web-based news feed (RSS/Atom) aggregator";
    license = licenses.gpl2Plus;
    homepage = "https://tt-rss.org";
    maintainers = with maintainers; [ globin zohl ];
    platforms = platforms.all;
  };
}
