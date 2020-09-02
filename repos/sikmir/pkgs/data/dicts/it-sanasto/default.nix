{ stdenvNoCC, lib, pandoc, stardict-tools, sources }:
let
  pname = "it-sanasto";
  date = lib.substring 0 10 sources.it-sanasto.date;
  version = "unstable-" + date;
in
stdenvNoCC.mkDerivation {
  inherit pname version;
  src = sources.it-sanasto;

  nativeBuildInputs = [ pandoc stardict-tools ];

  buildPhase = ''
    for i in *.md; do
      pandoc -f markdown -t html -s $i | awk -F "</*td>" '/<\/*td>.*/ {print $2}'
    done | paste -d"#" - - - | sed 's/#/\t/;s/#/\\n/' > ${pname}.tab

    stardict-tabfile ${pname}.tab
  '';

  installPhase = ''
    install -Dm644 ${pname}.{dict,idx,ifo} -t $out
  '';

  meta = with lib; {
    inherit (sources.it-sanasto) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
  };
}
