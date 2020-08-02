{ stdenv, fetchfromgh, undmg }:
let
  pname = "anki";
  version = "2.1.29";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchfromgh {
    owner = "ankitects";
    repo = "anki";
    name = "anki-${version}-mac.dmg";
    sha256 = "0cdswjn83cb360h0i0fckpyaj4qpra78qwxdg7ci9h327dan3z5k";
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
