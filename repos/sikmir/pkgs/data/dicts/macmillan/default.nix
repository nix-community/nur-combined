{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "macmillan";
  version = "2.4.2";

  src = fetchurl {
    url = "http://download.huzheng.org/bigdict/stardict-Macmillan_English_Dictionary-${version}.tar.bz2";
    sha256 = "1xg4xvxnni5vc371sd0bvskl1vly6p62q3c8r36bd2069ln7jy8r";
  };

  installPhase = ''
    install -dm755 "$out/share/goldendict/dictionaries/${pname}"
    cp -a . "$out/share/goldendict/dictionaries/${pname}"
  '';

  preferLocalBuild = true;

  meta = with stdenv.lib; {
    description = "Macmillan English Dictionary (En-En)";
    homepage = "http://download.huzheng.org/bigdict/";
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
