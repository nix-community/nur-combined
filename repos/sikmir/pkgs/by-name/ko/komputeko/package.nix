{
  lib,
  stdenvNoCC,
  fetchwebarchive,
  dict,
  jq,
  stardict-tools,
}:

stdenvNoCC.mkDerivation {
  pname = "komputeko";
  version = "2021-05-28";

  src = fetchwebarchive {
    url = "https://komputeko.net/data.json";
    timestamp = "20210630073336";
    hash = "sha256-dIvzbfqMjfogkj3Zld6lQ9PmNth712fw2lNr/OCvUEQ=";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    dict
    jq
    stardict-tools
  ];

  buildPhase = ''
    cat $src | \
      jq -r '.words[]|select(has("en") and has("eo"))|[.en[0].word,([.eo[].word]|join(", "))]|@tsv' > komputeko.tsv
    stardict-tabfile komputeko.tsv
  '';

  installPhase = "install -Dm644 *.{dict*,idx,ifo} -t $out";

  meta = {
    homepage = "https://komputeko.net/";
    description = "Prikomputila terminokolekto";
    maintainers = [ lib.maintainers.sikmir ];
    license = lib.licenses.cc-by-sa-40;
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
