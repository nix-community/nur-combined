{ stdenvNoCC, fetchurl, jq, stardict-tools }:

stdenvNoCC.mkDerivation {
  pname = "komputeko";
  version = "2020-06-23";

  src = fetchurl {
    url = "https://komputeko.net/data.json";
    sha256 = "11yjhp1pii74zs1i7lcih8spw447999mv0y3jzyglak2xdc293cs";
  };

  dontUnpack = true;

  nativeBuildInputs = [ jq stardict-tools ];

  buildPhase = ''
    cat $src | \
      jq -r '.words[]|select(has("en") and has("eo"))|[.en[0].word,([.eo[].word]|join(", "))]|@tsv' > komputeko.tsv
    stardict-tabfile komputeko.tsv
  '';

  installPhase = "install -Dm644 *.{dict,idx,ifo} -t $out";

  meta = with stdenvNoCC.lib; {
    homepage = "https://komputeko.net/";
    description = "Prikomputila terminokolekto";
    maintainers = [ maintainers.sikmir ];
    license = licenses.cc-by-sa-40;
    platforms = platforms.all;
    skip.ci = true;
  };
}
