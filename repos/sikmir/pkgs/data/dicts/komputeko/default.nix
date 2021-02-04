{ lib, stdenvNoCC, fetchwebarchive, dict, jq, stardict-tools }:

stdenvNoCC.mkDerivation {
  pname = "komputeko";
  version = "2020-10-18";

  src = fetchwebarchive {
    url = "https://komputeko.net/data.json";
    timestamp = "20201018194034";
    sha256 = "1bwzpxdk221cdya2sdc9cjvkl7qw1mk4yiy8mbdx8nmcm9m4adwc";
  };

  dontUnpack = true;

  nativeBuildInputs = [ dict jq stardict-tools ];

  buildPhase = ''
    cat $src | \
      jq -r '.words[]|select(has("en") and has("eo"))|[.en[0].word,([.eo[].word]|join(", "))]|@tsv' > komputeko.tsv
    stardict-tabfile komputeko.tsv
  '';

  installPhase = "install -Dm644 *.{dict*,idx,ifo} -t $out";

  meta = with lib; {
    homepage = "https://komputeko.net/";
    description = "Prikomputila terminokolekto";
    maintainers = [ maintainers.sikmir ];
    license = licenses.cc-by-sa-40;
    platforms = platforms.all;
    skip.ci = true;
  };
}
