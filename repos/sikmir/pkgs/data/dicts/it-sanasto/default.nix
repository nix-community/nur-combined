{ lib, stdenvNoCC, fetchFromGitHub, dict, pandoc, stardict-tools }:

stdenvNoCC.mkDerivation {
  pname = "it-sanasto";
  version = "2020-02-27";

  src = fetchFromGitHub {
    owner = "HankiDesign";
    repo = "IT-sanasto";
    rev = "e31974edd50a50db6ef1b95aab81a18f33800e67";
    sha256 = "sha256-+YLKG4kqflWkRdrER0A7GRYXluZpuf1TO0zyk3gVzU4=";
  };

  nativeBuildInputs = [ dict pandoc stardict-tools ];

  buildPhase = ''
    for i in *.md; do
      pandoc -f markdown -t html -s $i | awk -F "</*td>" '/<\/*td>.*/ {print $2}'
    done | paste -d"#" - - - | sed 's/#/\t/;s/#/\\n/' > it-sanasto.tab

    stardict-tabfile it-sanasto.tab
  '';

  installPhase = "install -Dm644 *.{dict*,idx,ifo} -t $out";

  meta = with lib; {
    description = "IT-alan englanti-suomi -sanasto";
    homepage = "https://github.com/HankiDesign/IT-sanasto";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
  };
}
