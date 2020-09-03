{ stdenv, fetchfromgh, undmg }:
let
  pname = "anki";
  version = "2.1.33";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchfromgh {
    owner = "ankitects";
    repo = "anki";
    name = "anki-${version}-mac.dmg";
    sha256 = "0a5wxmxzjn23w3c0jd3sk5mrsiapzfvjqz2sb0q2nmn62c7l2df5";
    inherit version;
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = "Anki.app";

  installPhase = ''
    mkdir -p $out/Applications/Anki.app
    cp -R . $out/Applications/Anki.app
  '';

  meta = with stdenv.lib; {
    homepage = "https://apps.ankiweb.net/";
    description = "Spaced repetition flashcard program";
    license = licenses.agpl3Plus;
    platforms = [ "x86_64-darwin" ];
    maintainers = [ maintainers.sikmir ];
    skip.ci = true;
  };
}
