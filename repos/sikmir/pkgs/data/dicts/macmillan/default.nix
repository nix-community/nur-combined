{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "macmillan";
  version = "2.4.2";

  src = fetchzip {
    url = "http://download.huzheng.org/bigdict/stardict-Macmillan_English_Dictionary-${version}.tar.bz2";
    sha256 = "171q6p6f81yi9gjk9rw49kfm2dr6c7aj6rpnavsn20g426pskj2r";
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
