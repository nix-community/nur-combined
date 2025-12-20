{
  lib,
  stdenvNoCC,
  sources,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "english-words";
  inherit (sources.english_words) src version;

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase = ''
    mkdir -p $out/share/english-words
    cp words*.txt $out/share/english-words/
    cp words*.json $out/share/english-words/
  '';

  meta = {
    description = "Text file containing 479k English words for all your dictionary/word-based projects.";
    homepage = "https://github.com/dwyl/english-words";
    platforms = lib.platforms.all;
    license = lib.licenses.free;
  };
})
