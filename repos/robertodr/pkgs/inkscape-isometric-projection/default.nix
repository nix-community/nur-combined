{ lib
, stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  pname = "inkscape-isometric-projection";
  version = "4.0";

  src = fetchFromGitHub {
    owner = "jdhoek";
    repo = "inkscape-isometric-projection";
    rev = "07c2778089962a60d4c1b2ffec6eb9fefc7d1fe1";
    hash = "sha256-vKh/SSjYk+yCSnLDbt9aKLHVDJFqenrDbBY8GktgL/g=";
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
