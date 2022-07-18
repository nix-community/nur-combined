{ lib
, stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  pname = "inkscape-isometric-projection";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "jdhoek";
    repo = "inkscape-isometric-projection";
    rev = "${version}";
    sha256 = "1ganair0ifza9lfjn17r84bx3yl9gyabgc9rnaz806pxwx3akik0";
  };

  installPhase = ''
    runHook preInstall

    install -Dt "$out/share/inkscape/extensions" *.inx *.py

    runHook postInstall
  '';

  meta = with lib; {
    description = "Inkscape extension for converting objects to an isometric projection";
    homepage = "https://github.com/jdhoek/inkscape-isometric-projection";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ robertodr ];
    platforms = platforms.all;
  };
}
