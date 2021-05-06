{ lib, stdenvNoCC, fetchurl, lang, version, hash }:

stdenvNoCC.mkDerivation {
  pname = "wiktionary-${lang}";
  inherit version;

  src = fetchurl {
    url = "http://libredict.org/dictionaries/${lang}/wiktionary_${lang}_stardict_${version}.tgz";
    inherit hash;
  };

  installPhase = "install -Dm644 *.{dict,idx,ifo} -t $out";

  preferLocalBuild = true;

  meta = with lib; {
    description = "Wiktionary dictionaries for StarDict (${lang})";
    homepage = "http://libredict.org/en/info_${lang}.html";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
