{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "webster";
  version = "2.4.2";

  src = fetchzip {
    url = "http://download.huzheng.org/bigdict/stardict-Webster_s_Unabridged_3-${version}.tar.bz2";
    sha256 = "0bbqawgvp1h4a403xa3f7n417gv9wxjgll8cymm75qsrh7z9w7c2";
  };

  installPhase = ''
    install -dm755 "$out/share/goldendict/dictionaries/${pname}"
    cp -a . "$out/share/goldendict/dictionaries/${pname}"
  '';

  preferLocalBuild = true;

  meta = with stdenv.lib; {
    description = "Webster's Third New International Dictionary, Unabridged (En-En)";
    homepage = "http://download.huzheng.org/bigdict/";
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
