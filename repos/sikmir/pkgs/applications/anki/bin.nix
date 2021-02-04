{ lib, stdenv, fetchfromgh, undmg }:

stdenv.mkDerivation rec {
  pname = "anki-bin";
  version = "2.1.37";

  src = fetchfromgh {
    owner = "ankitects";
    repo = "anki";
    name = "anki-${version}-mac.dmg";
    sha256 = "1f1ac6bwsw5vy08i5jr9xs14vhvja42ww7yv7gd96l4k7ij789rh";
    inherit version;
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = "Anki.app";

  installPhase = ''
    mkdir -p $out/Applications/Anki.app
    cp -r . $out/Applications/Anki.app
  '';

  meta = with lib; {
    homepage = "https://apps.ankiweb.net/";
    description = "Spaced repetition flashcard program";
    license = licenses.agpl3Plus;
    platforms = [ "x86_64-darwin" ];
    maintainers = [ maintainers.sikmir ];
    skip.ci = true;
  };
}
