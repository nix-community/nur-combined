{ stdenv, fetchurl, lang, version, sha256 }:

stdenv.mkDerivation rec {
  pname = "wiktionary-${lang}";
  inherit version;

  src = fetchurl {
    url = "http://libredict.org/dictionaries/${lang}/wiktionary_${lang}_stardict_${version}.tgz";
    inherit sha256;
  };

  installPhase = ''
    install -Dm644 *.{dict,idx,ifo} -t "$out/share/goldendict/dictionaries/wiktionary"
  '';

  preferLocalBuild = true;

  meta = with stdenv.lib; {
    description = "Wiktionary dictionaries for StarDict (${lang})";
    homepage = "http://libredict.org/en/info_${lang}.html";
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
