{ lib, stdenvNoCC, fetchurl, dict, jq, moreutils, stardict-tools, tatoebatools }:
let
  langs = [
    "deu eng"
    "deu rus"
    "eng deu"
    "eng epo"
    "eng fin"
    "eng rus"
    "eng swe"
    "eng ukr"
    "epo eng"
    "epo rus"
    "fin eng"
    "fin rus"
    "rus deu"
    "rus eng"
    "rus epo"
    "rus fin"
    "rus swe"
    "rus ukr"
    "swe eng"
    "swe rus"
    "ukr eng"
    "ukr rus"
  ];
  tatoeba = builtins.fromJSON (builtins.readFile ./tatoeba.json);
in
stdenvNoCC.mkDerivation rec {
  pname = "tatoeba";
  version = "2022-09-10";

  srcs = lib.mapAttrsToList (name: spec: fetchurl spec) tatoeba;

  unpackPhase = ''
    echo "{}" > versions.json
  '' + lib.concatMapStringsSep "\n"
    (src: ''
      bzcat ${src} > ${lib.removeSuffix ".bz2" src.name}
      jq '.+{"${lib.removeSuffix ".tsv.bz2" src.name}":"${version} 00:00:00"}' versions.json | \
        sponge versions.json
    '')
    srcs;

  nativeBuildInputs = [ dict jq moreutils stardict-tools tatoebatools ];

  buildPhase =
    let
      makeDict = lang: with lib; ''
        parallel_corpus ${lang} > tatoeba_${replaceStrings [ " " ] [ "_" ] lang}.tab
        stardict-tabfile tatoeba_${replaceStrings [ " " ] [ "_" ] lang}.tab
      '';
    in
    ''
      export XDG_DATA_HOME=$PWD
      mkdir -p tatoebatools/{links,sentences_detailed}
      mv *_links.tsv tatoebatools/links
      mv *_sentences_detailed.tsv tatoebatools/sentences_detailed
      mv versions.json tatoebatools
      ${lib.concatMapStringsSep "\n" makeDict langs}
    '';

  installPhase = "install -Dm644 *.{dict*,idx,ifo} -t $out";

  meta = with lib; {
    description = "Tatoeba is a collection of sentences and translations";
    homepage = "https://tatoeba.org/";
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
